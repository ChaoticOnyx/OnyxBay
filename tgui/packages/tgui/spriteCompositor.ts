/**
 * SpriteCompositor — Client-side character preview renderer.
 *
 * Loads pre-built sprite atlases and composites character layers
 * on an HTML5 Canvas, eliminating server round-trips for preview updates.
 *
 * Usage:
 *   const compositor = new SpriteCompositor();
 *   await compositor.init();
 *   const dataUrl = compositor.renderCharacter(config);
 */

// ================================================================
// Types
// ================================================================

/** Compact manifest entry: [atlasIndex, x, y] */
type SpriteLocation = [number, number, number];

interface SpriteManifest {
  spriteSize: number;
  atlasSize: number;
  atlases: string[];
  sprites: Record<string, Record<string, Record<string, SpriteLocation>>>;
}

/** Direction names matching atlas manifest keys */
type Direction = 'south' | 'north' | 'east' | 'west';

/** BYOND direction constants to manifest direction names */
const DIR_TO_NAME: Record<number, Direction> = {
  1: 'north',
  2: 'south',
  4: 'east',
  8: 'west',
};

/** Character render configuration — built from preference data */
export interface CharacterRenderConfig {
  // Species & body
  species: string;
  gender: string;
  bodyBuild: string; // "", "_slim", "_slim_alt", "_fat", etc.
  direction: number; // BYOND dir constant (1=N, 2=S, 4=E, 8=W)

  // Skin
  skinTone: number; // -220 to +34 (negative = darker)
  skinColor: string | null; // hex color like "#ff0000"

  // Hair
  hairStyle: string; // icon_state in the hair DMI
  hairColor: string; // hex
  secondaryHairColor: string | null; // hex, for _s states
  hairDmiFile: string; // resolved DMI path like "icons/mob/human_races/face/hair.dmi"

  // Facial hair
  facialStyle: string;
  facialColor: string;
  facialDmiFile: string;

  // Eyes
  eyeColor: string;

  // Body DMI (species icobase)
  bodyDmiFile: string; // e.g. "icons/mob/human_races/r_human.dmi"

  // Underwear layers
  underwear?: {
    state: string;
    color: string | null;
    dmiFile: string;
  }[];

  // Equipped clothing/gear — rendered in layer order
  clothing?: {
    state: string;
    dmiFile: string;
    color: string | null;
    layer: number;
  }[];

  // Organ state — for amputated/cybernetic limbs
  organData?: Record<string, string | null>;
  rlimbData?: Record<string, string | null>;
  // Robolimb brand name → DMI icon path mapping (resolved for current species)
  robolimbIcons?: Record<string, string>;

  // Skin markings (tattoos etc.) — drawn on body, above skin, below clothing
  markings?: {
    icon: string;
    iconState: string;
    organTag: string;
    color: string;
  }[];
  // Hair markings (fades/splits) — masked to hair shape, drawn with hair
  hairMarkings?: {
    icon: string;
    iconState: string;
    color: string;
  }[];

  // Equipment-driven hair visibility (matches BLOCKHAIR/BLOCKHEADHAIR flags)
  hideHair?: boolean;
  hideFacialHair?: boolean;
}

// ================================================================
// Body part definitions
// ================================================================

/**
 * Body parts to render, in draw order (back to front within body layer).
 * `tag` = icon_name (used for sprite state lookup in the DMI).
 * `organTag` = organ_tag (used for organ_data lookup, e.g. amputated/cyborg).
 * Gendered parts use _m/_f suffix; all parts use body build suffix.
 */
interface BodyPartDef {
  tag: string;
  organTag: string;
  gendered: boolean;
  side?: 'left' | 'right';
  skipIfFar?: boolean; // If true, skip rendering entirely when this part is on the far side
}

/**
 * Returns body parts in correct draw order for the given direction.
 * When facing east/west:
 *   - Far-side arms/legs are drawn before the torso (covered by torso)
 *   - Far-side hands are skipped entirely — their default-build sprites
 *     have stray pixels that extend below the torso and can't be covered
 *     (build-specific variants already have empty far-side frames)
 */
function getBodyPartsForDir(dir: Direction): BodyPartDef[] {
  const leftParts: BodyPartDef[] = [
    { tag: 'l_leg', organTag: 'l_leg', gendered: false, side: 'left' },
    { tag: 'l_arm', organTag: 'l_arm', gendered: false, side: 'left' },
    { tag: 'l_foot', organTag: 'l_foot', gendered: false, side: 'left' },
    { tag: 'l_hand', organTag: 'l_hand', gendered: false, side: 'left', skipIfFar: true },
  ];
  const rightParts: BodyPartDef[] = [
    { tag: 'r_leg', organTag: 'r_leg', gendered: false, side: 'right' },
    { tag: 'r_arm', organTag: 'r_arm', gendered: false, side: 'right' },
    { tag: 'r_foot', organTag: 'r_foot', gendered: false, side: 'right' },
    { tag: 'r_hand', organTag: 'r_hand', gendered: false, side: 'right', skipIfFar: true },
  ];

  if (dir === 'east') {
    // Facing right: left side is far, right side is near
    const farLimbs = leftParts.filter(p => !p.skipIfFar);
    return [
      ...farLimbs,
      { tag: 'torso', organTag: 'chest', gendered: true },
      { tag: 'groin', organTag: 'groin', gendered: true },
      ...rightParts,
      { tag: 'head', organTag: 'head', gendered: true },
    ];
  } else if (dir === 'west') {
    // Facing left: right side is far, left side is near
    const farLimbs = rightParts.filter(p => !p.skipIfFar);
    return [
      ...farLimbs,
      { tag: 'torso', organTag: 'chest', gendered: true },
      { tag: 'groin', organTag: 'groin', gendered: true },
      ...leftParts,
      { tag: 'head', organTag: 'head', gendered: true },
    ];
  } else {
    // North/south: no far/near distinction
    return [
      { tag: 'torso', organTag: 'chest', gendered: true },
      { tag: 'groin', organTag: 'groin', gendered: true },
      ...leftParts,
      ...rightParts,
      { tag: 'head', organTag: 'head', gendered: true },
    ];
  }
}

// ================================================================
// SpriteCompositor Class
// ================================================================

export class SpriteCompositor {
  private manifest: SpriteManifest | null = null;
  private atlases: HTMLImageElement[] = [];
  private loaded = false;
  private loadPromise: Promise<void> | null = null;
  private tempCanvas: HTMLCanvasElement;
  private tempCtx: CanvasRenderingContext2D;

  constructor() {
    // Temp canvas for color tinting operations
    this.tempCanvas = document.createElement('canvas');
    this.tempCanvas.width = 32;
    this.tempCanvas.height = 32;
    this.tempCtx = this.tempCanvas.getContext('2d')!;
  }

  /** Load manifest and all atlas images. Safe to call multiple times concurrently. */
  init(): Promise<void> {
    if (this.loaded) return Promise.resolve();
    if (this.loadPromise) return this.loadPromise;

    this.loadPromise = (async () => {
      const manifestResp = await fetch('manifest.json');
      if (!manifestResp.ok) {
        throw new Error(`Failed to load sprite manifest: ${manifestResp.status} ${manifestResp.statusText}. Run "npm run build-atlas" to generate sprites.`);
      }
      this.manifest = await manifestResp.json();

      // Resize temp canvas to match actual sprite size
      const spriteSize = this.manifest!.spriteSize;
      this.tempCanvas.width = spriteSize;
      this.tempCanvas.height = spriteSize;

      // Load all atlas images
      const loadPromises = this.manifest!.atlases.map((name, idx) => {
        return new Promise<void>((resolve, reject) => {
          const img = new Image();
          img.onload = () => {
            this.atlases[idx] = img;
            resolve();
          };
          img.onerror = () => reject(new Error(`Failed to load atlas: ${name}`));
          img.src = name;
        });
      });

      await Promise.all(loadPromises);
      this.loaded = true;
    })().catch((err) => {
      this.loadPromise = null;
      throw err;
    });

    return this.loadPromise;
  }

  /** Check if compositor is initialized and ready to render */
  isReady(): boolean {
    return this.loaded;
  }

  /** Check if a sprite exists in the manifest without fetching location data. */
  private hasSprite(dmiFile: string, state: string, dir: Direction): boolean {
    return this.getSprite(dmiFile, state, dir) !== null;
  }

  /**
   * Look up a sprite's location in the atlas.
   * Returns null if the sprite doesn't exist in the manifest.
   */
  private getSprite(dmiFile: string, state: string, dir: Direction): SpriteLocation | null {
    if (!this.manifest) return null;
    const dmi = this.manifest.sprites[dmiFile];
    if (!dmi) return null;
    const stateData = dmi[state];
    if (!stateData) return null;
    return stateData[dir] || null;
  }

  /**
   * Draw a single sprite from the atlas onto a target canvas context.
   */
  drawSprite(
    ctx: CanvasRenderingContext2D,
    dmiFile: string,
    state: string,
    dir: Direction,
    dx = 0,
    dy = 0,
  ): boolean {
    const loc = this.getSprite(dmiFile, state, dir);
    if (!loc) return false;

    const [atlasIdx, sx, sy] = loc;
    const atlas = this.atlases[atlasIdx];
    if (!atlas) return false;

    const size = this.manifest!.spriteSize;
    ctx.drawImage(atlas, sx, sy, size, size, dx, dy, size, size);
    return true;
  }

  /**
   * Draw a sprite with additive color tinting (ICON_ADD blend).
   * Matches BYOND's icon.Blend(color, ICON_ADD): adds color values to
   * each pixel. Result = sprite_pixel + tint_color (clamped to 255).
   *
   * Used for hair color, skin tone (positive), eye color.
   */
  drawSpriteTintedAdd(
    ctx: CanvasRenderingContext2D,
    dmiFile: string,
    state: string,
    dir: Direction,
    color: string,
    dx = 0,
    dy = 0,
  ): boolean {
    const loc = this.getSprite(dmiFile, state, dir);
    if (!loc) return false;

    const [atlasIdx, sx, sy] = loc;
    const atlas = this.atlases[atlasIdx];
    if (!atlas) return false;

    const size = this.manifest!.spriteSize;
    const tc = this.tempCtx;
    const tCanvas = this.tempCanvas;

    // Step 1: Draw sprite to temp canvas
    tc.clearRect(0, 0, size, size);
    tc.globalCompositeOperation = 'source-over';
    tc.drawImage(atlas, sx, sy, size, size, 0, 0, size, size);

    // Step 2: Create color fill masked to sprite alpha
    // 'source-atop' replaces RGB but keeps original alpha mask
    tc.globalCompositeOperation = 'source-atop';
    tc.fillStyle = color;
    tc.fillRect(0, 0, size, size);

    // Step 3: Draw the original sprite normally onto main canvas
    ctx.drawImage(atlas, sx, sy, size, size, dx, dy, size, size);

    // Step 4: Add the color shape on top (lighter = additive blend)
    // Result: original_sprite + color (where sprite alpha > 0)
    const prevOp = ctx.globalCompositeOperation;
    ctx.globalCompositeOperation = 'lighter';
    ctx.drawImage(tCanvas, dx, dy);
    ctx.globalCompositeOperation = prevOp;

    return true;
  }

  /**
   * Draw a sprite with multiply color (ICON_MULTIPLY blend).
   * Used for some species skin color.
   */
  drawSpriteTintedMultiply(
    ctx: CanvasRenderingContext2D,
    dmiFile: string,
    state: string,
    dir: Direction,
    color: string,
    dx = 0,
    dy = 0,
  ): boolean {
    const loc = this.getSprite(dmiFile, state, dir);
    if (!loc) return false;

    const [atlasIdx, sx, sy] = loc;
    const atlas = this.atlases[atlasIdx];
    if (!atlas) return false;

    const size = this.manifest!.spriteSize;
    const tc = this.tempCtx;
    const tCanvas = this.tempCanvas;

    // Draw sprite to temp canvas
    tc.clearRect(0, 0, size, size);
    tc.globalCompositeOperation = 'source-over';
    tc.drawImage(atlas, sx, sy, size, size, 0, 0, size, size);

    // Multiply with color
    tc.globalCompositeOperation = 'multiply';
    tc.fillStyle = color;
    tc.fillRect(0, 0, size, size);

    // Restore alpha from original sprite (multiply destroys alpha)
    tc.globalCompositeOperation = 'destination-in';
    tc.drawImage(atlas, sx, sy, size, size, 0, 0, size, size);

    // Draw to main canvas
    ctx.drawImage(tCanvas, dx, dy);

    return true;
  }

  /**
   * Draw a sprite with subtractive tint (ICON_SUBTRACT).
   * Used for negative skin tones.
   * Approximated as multiply with (255-r, 255-g, 255-b)/255 to avoid
   * getImageData which fails on tainted canvases.
   */
  drawSpriteTintedSubtract(
    ctx: CanvasRenderingContext2D,
    dmiFile: string,
    state: string,
    dir: Direction,
    r: number,
    g: number,
    b: number,
    dx = 0,
    dy = 0,
  ): boolean {
    // pixel - tone ≈ pixel * ((255 - tone) / 255)
    const mr = Math.max(0, 255 - r);
    const mg = Math.max(0, 255 - g);
    const mb = Math.max(0, 255 - b);
    return this.drawSpriteTintedMultiply(
      ctx, dmiFile, state, dir,
      `rgb(${mr},${mg},${mb})`,
      dx, dy,
    );
  }

  /**
   * Core rendering logic — composites all character layers onto the given context.
   * Called by both renderCharacter (data URL) and renderCharacterToCanvas (direct paint).
   */
  private renderLayers(
    ctx: CanvasRenderingContext2D,
    config: CharacterRenderConfig,
    dir: Direction,
  ): void {
    // === BODY LAYER ===
    this.renderBody(ctx, config, dir);

    // === EYES LAYER (below clothing so glasses cover them) ===
    const eyeState = 'eyes' + (config.bodyBuild || '');
    if (this.hasSprite(config.bodyDmiFile, eyeState, dir)) {
      this.drawSpriteTintedMultiply(ctx, config.bodyDmiFile, eyeState, dir, config.eyeColor);
    } else {
      this.drawSpriteTintedMultiply(ctx, config.bodyDmiFile, 'eyes', dir, config.eyeColor);
    }

    // === MARKINGS LAYER (above body, below clothing) ===
    if (config.markings) {
      for (const mark of config.markings) {
        this.drawSpriteTintedAdd(ctx, mark.icon, mark.iconState, dir, mark.color);
      }
    }

    // === UNDERWEAR LAYER ===
    if (config.underwear) {
      for (const uw of config.underwear) {
        if (uw.color) {
          this.drawSpriteTintedMultiply(ctx, uw.dmiFile, uw.state, dir, uw.color);
        } else {
          this.drawSprite(ctx, uw.dmiFile, uw.state, dir);
        }
      }
    }

    // === INTERLEAVED CLOTHING / FACIAL HAIR / HAIR ===
    const HO_FACIAL_HAIR = 19;
    const HO_HAIR = 26;
    const HO_FACEMASK = 29;

    const sorted = config.clothing
      ? [...config.clothing].sort((a, b) => a.layer - b.layer)
      : [];

    // Clothing below facial hair (uniform=10, shoes=13, gloves=14, belt=15, suit=17)
    for (const item of sorted) {
      if (item.layer >= HO_FACIAL_HAIR) break;
      this.drawClothingItem(ctx, item, dir);
    }

    // === FACIAL HAIR LAYER (19) ===
    if (!config.hideFacialHair && config.facialStyle && config.facialStyle !== 'Shaved') {
      this.drawSpriteTintedAdd(ctx, config.facialDmiFile, config.facialStyle, dir, config.facialColor);
    }

    // Clothing between facial hair and hair + facemask under hair
    for (const item of sorted) {
      if (item.layer < HO_FACIAL_HAIR || item.layer >= HO_HAIR) {
        if (item.layer !== HO_FACEMASK) continue;
      }
      this.drawClothingItem(ctx, item, dir);
    }

    // === HAIR LAYER (26) ===
    if (!config.hideHair && config.hairStyle && config.hairStyle !== 'Bald') {
      this.drawSpriteTintedAdd(ctx, config.hairDmiFile, config.hairStyle, dir, config.hairColor);

      if (config.hairMarkings) {
        for (const hm of config.hairMarkings) {
          this.drawHairMarking(ctx, config.hairDmiFile, config.hairStyle, hm, dir);
        }
      }

      if (config.secondaryHairColor) {
        const secondaryState = config.hairStyle + '_s';
        this.drawSpriteTintedAdd(ctx, config.hairDmiFile, secondaryState, dir, config.secondaryHairColor);
      }
    }

    // Clothing above hair (ears=28, head=30)
    for (const item of sorted) {
      if (item.layer < HO_HAIR || item.layer === HO_FACEMASK) continue;
      this.drawClothingItem(ctx, item, dir);
    }
  }

  /**
   * Render a full character preview.
   * Returns a data URL (PNG) suitable for <img> src.
   */
  renderCharacter(config: CharacterRenderConfig, outputSize = 192): string {
    if (!this.loaded || !this.manifest) return '';

    const size = this.manifest.spriteSize;
    const dir = DIR_TO_NAME[config.direction] || 'south';

    const canvas = document.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext('2d')!;
    ctx.imageSmoothingEnabled = false;

    this.renderLayers(ctx, config, dir);

    // Scale to output size
    if (outputSize !== size) {
      const outCanvas = document.createElement('canvas');
      outCanvas.width = outputSize;
      outCanvas.height = outputSize;
      const outCtx = outCanvas.getContext('2d')!;
      outCtx.imageSmoothingEnabled = false;
      outCtx.drawImage(canvas, 0, 0, size, size, 0, 0, outputSize, outputSize);
      return outCanvas.toDataURL('image/png');
    }

    return canvas.toDataURL('image/png');
  }

  /**
   * Render a character directly onto an existing canvas element.
   * Fully synchronous — no data URL round-trip, no async onload, no flicker.
   */
  renderCharacterToCanvas(
    config: CharacterRenderConfig,
    target: HTMLCanvasElement,
  ): void {
    if (!this.loaded || !this.manifest) return;

    const size = this.manifest.spriteSize;
    const outputSize = target.width;

    const src = document.createElement('canvas');
    src.width = size;
    src.height = size;
    const ctx = src.getContext('2d')!;
    ctx.imageSmoothingEnabled = false;

    const dir = DIR_TO_NAME[config.direction] || 'south';
    this.renderLayers(ctx, config, dir);

    // Blit offscreen canvas directly to target — single synchronous paint.
    // Use 'copy' composite so transparent pixels overwrite previous frame
    // without a visible blank-canvas flash between clearRect and drawImage.
    const tctx = target.getContext('2d')!;
    tctx.imageSmoothingEnabled = false;
    tctx.globalCompositeOperation = 'copy';
    tctx.drawImage(src, 0, 0, size, size, 0, 0, outputSize, outputSize);
    tctx.globalCompositeOperation = 'source-over';
  }

  /**
   * Render the body layer — all limbs with skin tone/color.
   */
  private renderBody(
    ctx: CanvasRenderingContext2D,
    config: CharacterRenderConfig,
    dir: Direction,
  ): void {
    const genderSuffix = config.gender === 'female' ? '_f' : '_m';
    const buildSuffix = config.bodyBuild || '';

    const bodyParts = getBodyPartsForDir(dir);
    for (const part of bodyParts) {
      // Skip amputated limbs (use organTag for organ_data lookup)
      if (config.organData && config.organData[part.organTag] === 'amputated') {
        continue;
      }

      // Determine state name with gender and body build suffixes.
      // Matches DM fallback logic: try full state, then without build, then just tag.
      let state: string;
      if (part.gendered) {
        const full = part.tag + genderSuffix + buildSuffix;
        const noBuild = part.tag + genderSuffix;
        if (this.hasSprite(config.bodyDmiFile, full, dir)) {
          state = full;
        } else if (this.hasSprite(config.bodyDmiFile, noBuild, dir)) {
          state = noBuild;
        } else {
          state = part.tag;
        }
      } else {
        const full = part.tag + buildSuffix;
        if (this.hasSprite(config.bodyDmiFile, full, dir)) {
          state = full;
        } else {
          state = part.tag;
        }
      }

      // Choose DMI file — cyberlimbs use their brand's DMI instead of body
      let dmiFile = config.bodyDmiFile;
      let isRobotic = false;
      if (config.organData && config.organData[part.organTag] === 'cyborg') {
        isRobotic = true;
        const brand = config.rlimbData?.[part.organTag];
        if (brand && config.robolimbIcons?.[brand]) {
          dmiFile = config.robolimbIcons[brand];
        }
      }

      // Draw the body part with appropriate coloring.
      // Matches BYOND's apply_colouration(): s_tone first, then s_col, applied sequentially.
      // Robotic limbs don't get skin tinting.
      if (isRobotic) {
        this.drawSprite(ctx, dmiFile, state, dir);
      } else {
        const hasTone = config.skinTone && config.skinTone !== 0;
        const hasColor = !!config.skinColor;

        if (!hasTone && !hasColor) {
          // No tinting — just draw
          this.drawSprite(ctx, dmiFile, state, dir);
        } else if (hasTone && !hasColor) {
          // Only skin tone
          this.applyBodyTone(ctx, dmiFile, state, dir, config.skinTone);
        } else if (!hasTone && hasColor) {
          // Only skin color (ICON_ADD)
          this.drawSpriteTintedAdd(ctx, dmiFile, state, dir, config.skinColor!);
        } else {
          // Both skin tone AND skin color (e.g. Golems, Prometheans).
          // Build on temp canvas: sprite → s_tone → s_col, then composite.
          this.applyBodyToneAndColor(ctx, dmiFile, state, dir,
            config.skinTone, config.skinColor!);
        }
      }
    }
  }

  /**
   * Apply skin tone only to a body sprite and draw to ctx.
   * Positive tone: ICON_ADD. Negative tone: ICON_SUBTRACT (approximated via multiply).
   */
  private applyBodyTone(
    ctx: CanvasRenderingContext2D,
    dmiFile: string, state: string, dir: Direction,
    skinTone: number,
  ): void {
    if (skinTone > 0) {
      const tone = Math.min(255, skinTone);
      this.drawSpriteTintedAdd(ctx, dmiFile, state, dir,
        `rgb(${tone},${tone},${tone})`);
    } else {
      const absTone = Math.min(255, Math.abs(skinTone));
      this.drawSpriteTintedSubtract(ctx, dmiFile, state, dir,
        absTone, absTone, absTone);
    }
  }

  /**
   * Apply skin tone THEN skin color sequentially (for species with both).
   * Matches BYOND: sprite.Blend(s_tone, ADD/SUBTRACT) then sprite.Blend(s_col, ADD)
   * Draws tone-adjusted sprite first, then adds skin color on top.
   */
  private applyBodyToneAndColor(
    ctx: CanvasRenderingContext2D,
    dmiFile: string, state: string, dir: Direction,
    skinTone: number, skinColor: string,
  ): void {
    // Step 1: Draw sprite with skin tone applied to main canvas
    this.applyBodyTone(ctx, dmiFile, state, dir, skinTone);

    // Step 2: Add skin color additively on top (masked to sprite alpha)
    const loc = this.getSprite(dmiFile, state, dir);
    if (!loc) return;
    const [atlasIdx, sx, sy] = loc;
    const atlas = this.atlases[atlasIdx];
    if (!atlas) return;
    const size = this.manifest!.spriteSize;
    const tc = this.tempCtx;
    const tCanvas = this.tempCanvas;

    tc.clearRect(0, 0, size, size);
    tc.globalCompositeOperation = 'source-over';
    tc.drawImage(atlas, sx, sy, size, size, 0, 0, size, size);
    tc.globalCompositeOperation = 'source-atop';
    tc.fillStyle = skinColor;
    tc.fillRect(0, 0, size, size);

    const prevOp = ctx.globalCompositeOperation;
    ctx.globalCompositeOperation = 'lighter';
    ctx.drawImage(tCanvas, 0, 0);
    ctx.globalCompositeOperation = prevOp;
  }

  /** Draw a single clothing/equipment overlay item. */
  private drawClothingItem(
    ctx: CanvasRenderingContext2D,
    item: { state: string; dmiFile: string; color: string | null; layer: number },
    dir: Direction,
  ): void {
    if (item.color) {
      this.drawSpriteTintedMultiply(ctx, item.dmiFile, item.state, dir, item.color);
    } else {
      this.drawSprite(ctx, item.dmiFile, item.state, dir);
    }
  }

  /**
   * Draw a hair marking (fade/split) masked to the hair shape.
   * BYOND: fade.Blend(hair, ICON_AND) → fade.Blend(color, ICON_MULTIPLY) → overlay
   * Canvas: draw fade, mask with hair via destination-in, multiply color, overlay.
   */
  private drawHairMarking(
    ctx: CanvasRenderingContext2D,
    hairDmiFile: string,
    hairState: string,
    marking: { icon: string; iconState: string; color: string },
    dir: Direction,
  ): void {
    // Fade markings often only have dirs=1 (south) — fall back to south if the
    // requested direction doesn't exist in the atlas.
    const fadeLoc = this.getSprite(marking.icon, marking.iconState, dir)
      ?? this.getSprite(marking.icon, marking.iconState, 'south');
    const hairLoc = this.getSprite(hairDmiFile, hairState, dir);
    if (!fadeLoc || !hairLoc) return;

    const size = this.manifest!.spriteSize;
    const tc = this.tempCtx;
    const tCanvas = this.tempCanvas;

    const [fadeAtlas, fadeSx, fadeSy] = fadeLoc;
    const [hairAtlas, hairSx, hairSy] = hairLoc;

    // Step 1: Draw the fade sprite to temp canvas
    tc.clearRect(0, 0, size, size);
    tc.globalCompositeOperation = 'source-over';
    tc.drawImage(this.atlases[fadeAtlas], fadeSx, fadeSy, size, size, 0, 0, size, size);

    // Step 2: Mask to hair shape (ICON_AND — keep only where hair has alpha)
    tc.globalCompositeOperation = 'destination-in';
    tc.drawImage(this.atlases[hairAtlas], hairSx, hairSy, size, size, 0, 0, size, size);

    // Step 3: Multiply with user color
    tc.globalCompositeOperation = 'multiply';
    tc.fillStyle = marking.color;
    tc.fillRect(0, 0, size, size);

    // Restore alpha (multiply affects alpha)
    tc.globalCompositeOperation = 'destination-in';
    tc.drawImage(this.atlases[fadeAtlas], fadeSx, fadeSy, size, size, 0, 0, size, size);
    tc.globalCompositeOperation = 'destination-in';
    tc.drawImage(this.atlases[hairAtlas], hairSx, hairSy, size, size, 0, 0, size, size);

    // Step 4: Overlay onto main canvas
    tc.globalCompositeOperation = 'source-over';
    ctx.drawImage(tCanvas, 0, 0);
  }

  /**
   * Render a small thumbnail preview (e.g. 64x64 for slot picker).
   */
  renderThumbnail(config: CharacterRenderConfig, outputSize = 64): string {
    return this.renderCharacter(config, outputSize);
  }

  /**
   * Render specific body parts as a solid-color silhouette for slot selection overlays.
   * Draws only the parts whose organTag matches the given list, then flood-fills
   * with `tintColor` (preserving per-pixel alpha from the original sprites).
   * Returns a data URL (PNG) at the requested output size.
   */
  renderBodyPartHighlight(
    config: CharacterRenderConfig,
    organTags: string[],
    tintColor: string,
    outputSize = 192,
  ): string {
    if (!this.loaded || !this.manifest) return '';

    const size = this.manifest.spriteSize;
    const dir = DIR_TO_NAME[config.direction] || 'south';
    const genderSuffix = config.gender === 'female' ? '_f' : '_m';
    const buildSuffix = config.bodyBuild || '';

    const canvas = document.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext('2d')!;
    ctx.imageSmoothingEnabled = false;

    const bodyParts = getBodyPartsForDir(dir);
    for (const part of bodyParts) {
      if (!organTags.includes(part.organTag)) continue;

      // Resolve state name — same fallback logic as renderBody()
      let state: string;
      if (part.gendered) {
        const full = part.tag + genderSuffix + buildSuffix;
        const noBuild = part.tag + genderSuffix;
        if (this.hasSprite(config.bodyDmiFile, full, dir)) state = full;
        else if (this.hasSprite(config.bodyDmiFile, noBuild, dir)) state = noBuild;
        else state = part.tag;
      } else {
        const full = part.tag + buildSuffix;
        state = this.hasSprite(config.bodyDmiFile, full, dir) ? full : part.tag;
      }

      // Use cyborg DMI if this limb is robotic
      let dmiFile = config.bodyDmiFile;
      if (config.organData?.[part.organTag] === 'cyborg') {
        const brand = config.rlimbData?.[part.organTag];
        if (brand && config.robolimbIcons?.[brand]) dmiFile = config.robolimbIcons[brand];
      }

      this.drawSprite(ctx, dmiFile, state, dir);
    }

    // Flood-fill all drawn pixels with tint color, preserving their alpha shape
    ctx.globalCompositeOperation = 'source-atop';
    ctx.fillStyle = tintColor;
    ctx.fillRect(0, 0, size, size);
    ctx.globalCompositeOperation = 'source-over';

    // Scale to output size
    if (outputSize !== size) {
      const outCanvas = document.createElement('canvas');
      outCanvas.width = outputSize;
      outCanvas.height = outputSize;
      const outCtx = outCanvas.getContext('2d')!;
      outCtx.imageSmoothingEnabled = false;
      outCtx.drawImage(canvas, 0, 0, size, size, 0, 0, outputSize, outputSize);
      return outCanvas.toDataURL();
    }

    return canvas.toDataURL();
  }

  /**
   * Render a single equipment sprite as a solid-color silhouette.
   * Used for slots (Eyes, Mask, etc.) that don't correspond to a raw body part
   * but have a recognizable clothing shape to use as the hit area.
   */
  renderEquipmentHighlight(
    direction: number,
    dmiFile: string,
    state: string,
    tintColor: string,
    outputSize = 192,
  ): string {
    if (!this.loaded || !this.manifest) return '';

    const dir = DIR_TO_NAME[direction] || 'south';
    const size = this.manifest.spriteSize;

    const canvas = document.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext('2d')!;
    ctx.imageSmoothingEnabled = false;

    this.drawSprite(ctx, dmiFile, state, dir);

    ctx.globalCompositeOperation = 'source-atop';
    ctx.fillStyle = tintColor;
    ctx.fillRect(0, 0, size, size);
    ctx.globalCompositeOperation = 'source-over';

    if (outputSize !== size) {
      const outCanvas = document.createElement('canvas');
      outCanvas.width = outputSize;
      outCanvas.height = outputSize;
      const outCtx = outCanvas.getContext('2d')!;
      outCtx.imageSmoothingEnabled = false;
      outCtx.drawImage(canvas, 0, 0, size, size, 0, 0, outputSize, outputSize);
      return outCanvas.toDataURL();
    }

    return canvas.toDataURL();
  }

  /**
   * Render a single item icon (for gear list / detail views).
   * Returns a data URL or empty string if the sprite isn't found.
   */
  renderItemIcon(dmiFile: string, state: string, outputSize = 32, color?: string): string {
    if (!this.loaded || !this.manifest) return '';

    const size = this.manifest.spriteSize;
    const canvas = document.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext('2d')!;

    if (color) {
      this.drawSpriteTintedMultiply(ctx, dmiFile, state, 'south', color);
    } else {
      this.drawSprite(ctx, dmiFile, state, 'south');
    }

    // Scale if needed
    if (outputSize !== size) {
      const outCanvas = document.createElement('canvas');
      outCanvas.width = outputSize;
      outCanvas.height = outputSize;
      const outCtx = outCanvas.getContext('2d')!;
      outCtx.imageSmoothingEnabled = false;
      outCtx.drawImage(canvas, 0, 0, outputSize, outputSize);
      return outCanvas.toDataURL();
    }

    return canvas.toDataURL();
  }
}

// Singleton instance
let compositorInstance: SpriteCompositor | null = null;

export function getCompositor(): SpriteCompositor {
  if (!compositorInstance) {
    compositorInstance = new SpriteCompositor();
  }
  return compositorInstance;
}
