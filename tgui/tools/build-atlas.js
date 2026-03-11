#!/usr/bin/env node
/**
 * Build Atlas — extracts sprites from BYOND .dmi files and packs them into
 * sprite atlas sheets with a JSON manifest for client-side rendering.
 *
 * Usage:
 *   node tools/build-atlas.js            # build if sources changed
 *   node tools/build-atlas.js --force    # always rebuild
 *
 * Output: public/sprites/atlas-*.png + manifest.json
 */

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { PNG } = require("pngjs");
const {
  parseDmi,
  extractSprite,
  isSpriteEmpty,
  DIR_SOUTH,
  DIR_NORTH,
  DIR_EAST,
  DIR_WEST,
} = require("./dmi-parser");

// ============================================================
// Configuration
// ============================================================

const REPO_ROOT = path.resolve(__dirname, "../..");
const ICONS_DIR = path.join(REPO_ROOT, "icons");
const OUTPUT_DIR = path.join(__dirname, "../public/sprites");
const CACHE_FILE = path.join(OUTPUT_DIR, ".atlas-cache");

const ATLAS_SIZE = 2048;
const SPRITE_SIZE = 32;
const SPRITES_PER_ROW = Math.floor(ATLAS_SIZE / SPRITE_SIZE);
const SPRITES_PER_ATLAS = SPRITES_PER_ROW * SPRITES_PER_ROW;

const DIRECTIONS = [DIR_SOUTH, DIR_NORTH, DIR_EAST, DIR_WEST];
const DIR_NAMES = ["south", "north", "east", "west"];

// ============================================================
// Target DMI files
// ============================================================

function getTargetDmiFiles() {
  const targets = [];

  addGlob(targets, "mob/human_races", "r_*.dmi");
  addGlob(targets, "mob/human_races/face", "hair*.dmi");
  addGlob(targets, "mob/human_races/face", "facial*.dmi");
  addFile(targets, "mob/human_races/markings.dmi");
  addFile(targets, "mob/human_races/hair_fade.dmi");
  addGlob(targets, "inv_slots/hidden", "mob*.dmi");

  const clothingSlots = [
    "uniforms",
    "suits",
    "hats",
    "shoes",
    "gloves",
    "glasses",
    "masks",
    "belts",
    "back",
    "acessories",
    "ears",
    "suitstorage",
    "rig",
  ];
  for (const slot of clothingSlots) {
    addGlob(targets, `inv_slots/${slot}`, "mob*.dmi");
  }

  addGlobRecursive(targets, "mob/human_races/cyberlimbs", "*.dmi");
  addFile(targets, "mob/onmob/id.dmi");
  addGlob(targets, "obj/clothing", "*.dmi");
  addFile(targets, "obj/items.dmi");
  addFile(targets, "obj/weapons.dmi");
  addFile(targets, "obj/toy.dmi");
  addFile(targets, "obj/zippos.dmi");
  addFile(targets, "obj/cigarettes.dmi");
  addFile(targets, "obj/food.dmi");
  addFile(targets, "obj/chemical.dmi");
  addFile(targets, "obj/card.dmi");
  addFile(targets, "obj/device.dmi");
  addFile(targets, "obj/wallet.dmi");
  addFile(targets, "obj/welding_covers.dmi");
  addGlob(targets, "obj/storage", "*.dmi");

  return targets;
}

function addFile(targets, relativePath) {
  const fullPath = path.join(ICONS_DIR, relativePath);
  if (fs.existsSync(fullPath)) {
    targets.push(relativePath);
  }
}

function globToRegex(pattern) {
  return new RegExp(
    "^" +
      pattern.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*") +
      "$",
  );
}

function addGlob(targets, dir, pattern) {
  const dirPath = path.join(ICONS_DIR, dir);
  if (!fs.existsSync(dirPath)) return;
  const regex = globToRegex(pattern);
  for (const file of fs.readdirSync(dirPath)) {
    if (regex.test(file)) {
      targets.push(path.join(dir, file).replace(/\\/g, "/"));
    }
  }
}

function addGlobRecursive(targets, dir, pattern) {
  const dirPath = path.join(ICONS_DIR, dir);
  if (!fs.existsSync(dirPath)) return;
  const regex = globToRegex(pattern);
  function walk(currentDir, relativeBase) {
    for (const entry of fs.readdirSync(currentDir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        walk(
          path.join(currentDir, entry.name),
          path.join(relativeBase, entry.name),
        );
      } else if (regex.test(entry.name)) {
        targets.push(path.join(relativeBase, entry.name).replace(/\\/g, "/"));
      }
    }
  }
  walk(dirPath, dir);
}

// ============================================================
// Cache / Lazy Rebuild
// ============================================================

/**
 * Compute a SHA-256 hash covering:
 *  - content of this script + dmi-parser.js (logic changes → rebuild)
 *  - path + mtime + size of every input DMI file (data changes → rebuild)
 */
function computeInputHash(targetFiles) {
  const hash = crypto.createHash("sha256");

  // Hash build scripts themselves so logic changes trigger rebuild
  const scriptFiles = [__filename, path.join(__dirname, "dmi-parser.js")];
  for (const sf of scriptFiles) {
    try {
      hash.update(fs.readFileSync(sf));
    } catch {
      hash.update(sf + ":missing");
    }
  }

  // Hash every input DMI by path + mtime + size (fast, no content read)
  for (const file of targetFiles.sort()) {
    const fullPath = path.join(ICONS_DIR, file);
    try {
      const stat = fs.statSync(fullPath);
      hash.update(`${file}:${stat.mtimeMs}:${stat.size}\n`);
    } catch {
      hash.update(`${file}:missing\n`);
    }
  }

  return hash.digest("hex");
}

/**
 * Returns true if the atlas needs to be rebuilt.
 * Checks: output exists, cache file exists, hash matches.
 */
function needsRebuild() {
  // No icons directory — nothing to build
  if (!fs.existsSync(ICONS_DIR)) {
    return false;
  }

  // No manifest — definitely need to build
  const manifestPath = path.join(OUTPUT_DIR, "manifest.json");
  if (!fs.existsSync(manifestPath)) {
    return true;
  }

  // No cache — need to build
  if (!fs.existsSync(CACHE_FILE)) {
    return true;
  }

  try {
    const cachedHash = fs.readFileSync(CACHE_FILE, "utf-8").trim();
    const targetFiles = getTargetDmiFiles();
    const currentHash = computeInputHash(targetFiles);
    return cachedHash !== currentHash;
  } catch {
    return true;
  }
}

/**
 * Persist the current input hash so subsequent runs can skip rebuild.
 */
function saveCache(targetFiles) {
  const currentHash = computeInputHash(targetFiles);
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  fs.writeFileSync(CACHE_FILE, currentHash);
}

// ============================================================
// Atlas Packing
// ============================================================

function buildAtlases() {
  if (!fs.existsSync(ICONS_DIR)) {
    console.warn(
      `⚠️  Icons directory not found: ${ICONS_DIR}\n   Sprite atlas build skipped.`,
    );
    return null;
  }

  const targetFiles = getTargetDmiFiles();
  console.log(`Found ${targetFiles.length} DMI files to process.`);

  // Manifest structure: { atlases: [...], sprites: { [dmiPath]: { [state]: { [dir]: { atlas, x, y } } } } }
  const manifest = {
    spriteSize: SPRITE_SIZE,
    atlasSize: ATLAS_SIZE,
    atlases: [],
    sprites: {},
  };

  const allSprites = [];
  let skippedEmpty = 0;
  let totalExtracted = 0;

  for (const dmiPath of targetFiles) {
    const fullPath = path.join(ICONS_DIR, dmiPath);
    let dmi;
    try {
      dmi = parseDmi(fullPath);
    } catch (e) {
      console.warn(`  WARN: Failed to parse ${dmiPath}: ${e.message}`);
      continue;
    }

    const manifestKey = "icons/" + dmiPath;

    for (let si = 0; si < dmi.states.length; si++) {
      const state = dmi.states[si];
      // Only extract first frame (frame 0) for each direction
      for (let di = 0; di < DIRECTIONS.length; di++) {
        const dir = DIRECTIONS[di];
        if (dir >= state.dirs) continue;

        let pixels;
        try {
          pixels = extractSprite(dmi, si, dir, 0);
        } catch {
          continue;
        }

        totalExtracted++;

        // Skip completely transparent sprites to save atlas space
        if (isSpriteEmpty(pixels)) {
          skippedEmpty++;
          continue;
        }

        allSprites.push({
          dmiPath: manifestKey,
          state: state.name,
          dir: DIR_NAMES[di],
          pixels,
        });
      }
    }

    process.stdout.write(
      `\r  Processed ${dmiPath} (${dmi.states.length} states)`,
    );
  }
  console.log(
    `\nExtracted ${totalExtracted} sprite frames, skipped ${skippedEmpty} empty, packing ${allSprites.length} sprites.`,
  );

  // Pack sprites into atlas sheets
  const atlasCount = Math.ceil(allSprites.length / SPRITES_PER_ATLAS);
  console.log(
    `Creating ${atlasCount} atlas sheet(s) at ${ATLAS_SIZE}x${ATLAS_SIZE}...`,
  );

  // Ensure output directory exists
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  // Clean old atlas-*.png files before writing new ones
  for (const file of fs.readdirSync(OUTPUT_DIR)) {
    if (file.startsWith("atlas-") && file.endsWith(".png")) {
      fs.unlinkSync(path.join(OUTPUT_DIR, file));
    }
  }

  for (let ai = 0; ai < atlasCount; ai++) {
    const atlasName = `atlas-${ai}.png`;
    manifest.atlases.push(atlasName);

    const atlas = new PNG({ width: ATLAS_SIZE, height: ATLAS_SIZE });
    // Initialize to transparent
    atlas.data.fill(0);

    const startIdx = ai * SPRITES_PER_ATLAS;
    const endIdx = Math.min(startIdx + SPRITES_PER_ATLAS, allSprites.length);

    for (let i = startIdx; i < endIdx; i++) {
      const sprite = allSprites[i];
      const localIdx = i - startIdx;
      const col = localIdx % SPRITES_PER_ROW;
      const row = Math.floor(localIdx / SPRITES_PER_ROW);
      const dstX = col * SPRITE_SIZE;
      const dstY = row * SPRITE_SIZE;

      // Copy pixel data into atlas
      for (let y = 0; y < SPRITE_SIZE; y++) {
        for (let x = 0; x < SPRITE_SIZE; x++) {
          const srcIdx = (y * SPRITE_SIZE + x) * 4;
          const dstIdx = ((dstY + y) * ATLAS_SIZE + (dstX + x)) * 4;
          atlas.data[dstIdx] = sprite.pixels[srcIdx];
          atlas.data[dstIdx + 1] = sprite.pixels[srcIdx + 1];
          atlas.data[dstIdx + 2] = sprite.pixels[srcIdx + 2];
          atlas.data[dstIdx + 3] = sprite.pixels[srcIdx + 3];
        }
      }

      // Add to manifest — compact format: [atlas, x, y]
      if (!manifest.sprites[sprite.dmiPath]) {
        manifest.sprites[sprite.dmiPath] = {};
      }
      if (!manifest.sprites[sprite.dmiPath][sprite.state]) {
        manifest.sprites[sprite.dmiPath][sprite.state] = {};
      }
      manifest.sprites[sprite.dmiPath][sprite.state][sprite.dir] = [
        ai,
        dstX,
        dstY,
      ];
    }

    const atlasPath = path.join(OUTPUT_DIR, atlasName);
    const buffer = PNG.sync.write(atlas, { colorType: 6, filterType: 4 });
    fs.writeFileSync(atlasPath, buffer);
    const sizeMB = (buffer.length / 1024 / 1024).toFixed(2);
    console.log(
      `  Wrote ${atlasName}: ${endIdx - startIdx} sprites, ${sizeMB} MB`,
    );
  }

  const manifestPath = path.join(OUTPUT_DIR, "manifest.json");
  const manifestJson = JSON.stringify(manifest);
  fs.writeFileSync(manifestPath, manifestJson);
  const manifestSizeMB = (
    Buffer.byteLength(manifestJson) /
    1024 /
    1024
  ).toFixed(2);
  console.log(
    `  Wrote manifest.json: ${Object.keys(manifest.sprites).length} DMI files, ${manifestSizeMB} MB`,
  );

  console.log("\n=== Atlas Build Complete ===");
  console.log(`  DMI files processed: ${targetFiles.length}`);
  console.log(`  Total sprites packed: ${allSprites.length}`);
  console.log(`  Atlas sheets: ${atlasCount}`);
  console.log(`  Output: ${OUTPUT_DIR}`);

  // Persist cache so next build can skip if nothing changed
  saveCache(targetFiles);

  return manifest;
}

if (require.main === module) {
  const force = process.argv.includes("--force");

  if (!force && !needsRebuild()) {
    console.log("🎨 Sprite atlas is up to date (use --force to rebuild).");
    process.exit(0);
  }

  const startTime = Date.now();
  buildAtlases();
  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log(`  Time: ${elapsed}s`);
}

module.exports = { buildAtlases, needsRebuild };
