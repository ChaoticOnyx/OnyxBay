#!/usr/bin/env node
/**
 * Build Atlas — extracts sprites from BYOND .dmi files and packs them into
 * sprite atlas sheets with a JSON manifest for client-side rendering.
 *
 * Usage: node tools/build-atlas.js
 * Output: packages/tgui/assets/sprites/atlas-*.png + manifest.json
 */

const fs = require('fs');
const path = require('path');
const { PNG } = require('pngjs');
const { parseDmi, extractSprite, isSpriteEmpty, DIR_SOUTH, DIR_NORTH, DIR_EAST, DIR_WEST } = require('./dmi-parser');

// ============================================================
// Configuration
// ============================================================

const REPO_ROOT = path.resolve(__dirname, '../..');
const ICONS_DIR = path.join(REPO_ROOT, 'icons');
const OUTPUT_DIR = path.join(__dirname, '../public/sprites');

// Atlas dimensions (power of 2 for GPU friendliness)
const ATLAS_SIZE = 2048;
const SPRITE_SIZE = 32; // All character sprites are 32x32
const SPRITES_PER_ROW = Math.floor(ATLAS_SIZE / SPRITE_SIZE); // 64
const SPRITES_PER_ATLAS = SPRITES_PER_ROW * SPRITES_PER_ROW; // 4096

// Which directions to extract (all 4 for rotatable preview)
const DIRECTIONS = [DIR_SOUTH, DIR_NORTH, DIR_EAST, DIR_WEST];
const DIR_NAMES = ['south', 'north', 'east', 'west'];

/**
 * All DMI files to include in the atlas.
 * Paths are relative to the icons/ directory.
 * We use glob patterns resolved manually.
 */
function getTargetDmiFiles() {
  const targets = [];

  // Body sprites — species base bodies
  addGlob(targets, 'mob/human_races', 'r_*.dmi');

  // Hair
  addGlob(targets, 'mob/human_races/face', 'hair*.dmi');

  // Facial hair
  addGlob(targets, 'mob/human_races/face', 'facial*.dmi');

  // Markings
  addFile(targets, 'mob/human_races/markings.dmi');
  addFile(targets, 'mob/human_races/hair_fade.dmi');

  // Underwear
  addGlob(targets, 'inv_slots/hidden', 'mob*.dmi');

  // Clothing — all on-mob .dmi files per slot
  const clothingSlots = [
    'uniforms', 'suits', 'hats', 'shoes', 'gloves',
    'glasses', 'masks', 'belts', 'back', 'acessories',
    'ears', 'suitstorage', 'rig',
  ];
  for (const slot of clothingSlots) {
    addGlob(targets, `inv_slots/${slot}`, 'mob*.dmi');
  }

  // Cyberlimbs
  addGlobRecursive(targets, 'mob/human_races/cyberlimbs', '*.dmi');

  // ID overlay
  addFile(targets, 'mob/onmob/id.dmi');

  // === Inventory / world item sprites (for loadout gear icons) ===

  // Clothing inventory icons
  addGlob(targets, 'obj/clothing', '*.dmi');

  // Misc item icons used by loadout gear
  addFile(targets, 'obj/items.dmi');
  addFile(targets, 'obj/weapons.dmi');
  addFile(targets, 'obj/toy.dmi');
  addFile(targets, 'obj/zippos.dmi');
  addFile(targets, 'obj/cigarettes.dmi');
  addFile(targets, 'obj/food.dmi');
  addFile(targets, 'obj/chemical.dmi');
  addFile(targets, 'obj/card.dmi');
  addFile(targets, 'obj/device.dmi');
  addFile(targets, 'obj/wallet.dmi');
  addFile(targets, 'obj/welding_covers.dmi');
  addGlob(targets, 'obj/storage', '*.dmi');

  return targets;
}

function addFile(targets, relativePath) {
  const fullPath = path.join(ICONS_DIR, relativePath);
  if (fs.existsSync(fullPath)) {
    targets.push(relativePath);
  }
}

function globToRegex(pattern) {
  return new RegExp('^' + pattern.replace(/[.+^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*') + '$');
}

function addGlob(targets, dir, pattern) {
  const dirPath = path.join(ICONS_DIR, dir);
  if (!fs.existsSync(dirPath)) return;
  const regex = globToRegex(pattern);
  for (const file of fs.readdirSync(dirPath)) {
    if (regex.test(file)) {
      targets.push(path.join(dir, file).replace(/\\/g, '/'));
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
        walk(path.join(currentDir, entry.name), path.join(relativeBase, entry.name));
      } else if (regex.test(entry.name)) {
        targets.push(path.join(relativeBase, entry.name).replace(/\\/g, '/'));
      }
    }
  }
  walk(dirPath, dir);
}

// ============================================================
// Atlas Packing
// ============================================================

function buildAtlases() {
  const targetFiles = getTargetDmiFiles();
  console.log(`Found ${targetFiles.length} DMI files to process.`);

  // Manifest structure: { atlases: [...], sprites: { [dmiPath]: { [state]: { [dir]: { atlas, x, y } } } } }
  const manifest = {
    spriteSize: SPRITE_SIZE,
    atlasSize: ATLAS_SIZE,
    atlases: [],
    sprites: {},
  };

  // Collect all sprites first
  const allSprites = []; // { dmiPath, state, dir, pixels }
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

    // Normalize path for manifest key (use icons/ relative path)
    const manifestKey = 'icons/' + dmiPath;

    for (let si = 0; si < dmi.states.length; si++) {
      const state = dmi.states[si];
      // Only extract first frame (frame 0) for each direction
      for (let di = 0; di < DIRECTIONS.length; di++) {
        const dir = DIRECTIONS[di];
        if (dir >= state.dirs) continue; // Skip directions this state doesn't have

        let pixels;
        try {
          pixels = extractSprite(dmi, si, dir, 0);
        } catch (e) {
          continue; // Skip sprites that can't be extracted
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

    process.stdout.write(`\r  Processed ${dmiPath} (${dmi.states.length} states)`);
  }
  console.log(`\nExtracted ${totalExtracted} sprite frames, skipped ${skippedEmpty} empty, packing ${allSprites.length} sprites.`);

  // Pack sprites into atlas sheets
  const atlasCount = Math.ceil(allSprites.length / SPRITES_PER_ATLAS);
  console.log(`Creating ${atlasCount} atlas sheet(s) at ${ATLAS_SIZE}x${ATLAS_SIZE}...`);

  // Ensure output directory exists
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });

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
      manifest.sprites[sprite.dmiPath][sprite.state][sprite.dir] = [ai, dstX, dstY];
    }

    // Write atlas PNG
    const atlasPath = path.join(OUTPUT_DIR, atlasName);
    const buffer = PNG.sync.write(atlas, { colorType: 6, filterType: 4 });
    fs.writeFileSync(atlasPath, buffer);
    const sizeMB = (buffer.length / 1024 / 1024).toFixed(2);
    console.log(`  Wrote ${atlasName}: ${endIdx - startIdx} sprites, ${sizeMB} MB`);
  }

  // Write manifest
  const manifestPath = path.join(OUTPUT_DIR, 'manifest.json');
  const manifestJson = JSON.stringify(manifest);
  fs.writeFileSync(manifestPath, manifestJson);
  const manifestSizeMB = (Buffer.byteLength(manifestJson) / 1024 / 1024).toFixed(2);
  console.log(`  Wrote manifest.json: ${Object.keys(manifest.sprites).length} DMI files, ${manifestSizeMB} MB`);

  // Summary
  console.log('\n=== Atlas Build Complete ===');
  console.log(`  DMI files processed: ${targetFiles.length}`);
  console.log(`  Total sprites packed: ${allSprites.length}`);
  console.log(`  Atlas sheets: ${atlasCount}`);
  console.log(`  Output: ${OUTPUT_DIR}`);

  return manifest;
}

// ============================================================
// Main
// ============================================================

if (require.main === module) {
  const startTime = Date.now();
  buildAtlases();
  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log(`  Time: ${elapsed}s`);
}

module.exports = { buildAtlases };
