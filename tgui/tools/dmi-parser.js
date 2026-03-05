/**
 * DMI Parser — reads BYOND .dmi files and extracts sprite metadata + pixel data.
 *
 * DMI files are PNGs with a zTXt chunk (keyword "Description") containing
 * state definitions. Sprites are tiled left-to-right, top-to-bottom in the PNG.
 * Each state occupies dirs × frames cells.
 *
 * Direction order: SOUTH(0), NORTH(1), EAST(2), WEST(3)
 */

const fs = require('fs');
const zlib = require('zlib');
const { PNG } = require('pngjs');

// BYOND direction indices in DMI sprite order
const DIR_SOUTH = 0;
const DIR_NORTH = 1;
const DIR_EAST = 2;
const DIR_WEST = 3;

/**
 * Parse a DMI file and return metadata + pixel data.
 * @param {string} filePath - Path to the .dmi file
 * @returns {{ width: number, height: number, pngWidth: number, pngHeight: number, states: DmiState[], png: PNG }}
 */
function parseDmi(filePath) {
  const fileData = fs.readFileSync(filePath);

  // Parse the PNG pixel data
  const png = PNG.sync.read(fileData);

  // Extract zTXt metadata from raw PNG chunks
  const metadata = extractDmiMetadata(fileData);
  if (!metadata) {
    throw new Error(`No DMI metadata found in ${filePath}`);
  }

  const parsed = parseDmiText(metadata);

  return {
    spriteWidth: parsed.width,
    spriteHeight: parsed.height,
    pngWidth: png.width,
    pngHeight: png.height,
    states: parsed.states,
    png,
  };
}

/**
 * Extract the DMI description text from PNG zTXt chunks.
 */
function extractDmiMetadata(pngBuffer) {
  let offset = 8; // Skip PNG signature
  while (offset < pngBuffer.length - 8) {
    const length = pngBuffer.readUInt32BE(offset);
    const type = pngBuffer.slice(offset + 4, offset + 8).toString('ascii');

    if (type === 'zTXt') {
      const chunkData = pngBuffer.slice(offset + 8, offset + 8 + length);
      const nullIdx = chunkData.indexOf(0);
      const keyword = chunkData.slice(0, nullIdx).toString('ascii');
      if (keyword === 'Description') {
        const compressed = chunkData.slice(nullIdx + 2); // skip null + compression method byte
        return zlib.inflateSync(compressed).toString('utf-8');
      }
    }

    // Also check tEXt chunks (uncompressed)
    if (type === 'tEXt') {
      const chunkData = pngBuffer.slice(offset + 8, offset + 8 + length);
      const nullIdx = chunkData.indexOf(0);
      const keyword = chunkData.slice(0, nullIdx).toString('ascii');
      if (keyword === 'Description') {
        return chunkData.slice(nullIdx + 1).toString('utf-8');
      }
    }

    offset += 12 + length; // 4 length + 4 type + data + 4 CRC
  }
  return null;
}

/**
 * Parse DMI description text into structured state data.
 */
function parseDmiText(text) {
  const lines = text.split('\n');
  let width = 32;
  let height = 32;
  const states = [];
  let currentState = null;

  for (const rawLine of lines) {
    const line = rawLine.trim();

    if (line.startsWith('# BEGIN DMI') || line.startsWith('# END DMI') || !line) {
      continue;
    }

    if (line.startsWith('version')) {
      continue;
    }

    const eqIdx = line.indexOf('=');
    if (eqIdx === -1) continue;

    const key = line.substring(0, eqIdx).trim();
    let value = line.substring(eqIdx + 1).trim();

    if (key === 'width') {
      width = parseInt(value, 10);
    } else if (key === 'height') {
      height = parseInt(value, 10);
    } else if (key === 'state') {
      // Remove quotes
      value = value.replace(/^"(.*)"$/, '$1');
      currentState = {
        name: value,
        dirs: 1,
        frames: 1,
        delay: null,
        loop: 0,
        rewind: false,
        hotspot: null,
      };
      states.push(currentState);
    } else if (currentState) {
      switch (key) {
        case 'dirs':
          currentState.dirs = parseInt(value, 10);
          break;
        case 'frames':
          currentState.frames = parseInt(value, 10);
          break;
        case 'delay':
          currentState.delay = value.split(',').map(Number);
          break;
        case 'loop':
          currentState.loop = parseInt(value, 10);
          break;
        case 'rewind':
          currentState.rewind = value === '1';
          break;
        case 'hotspot':
          currentState.hotspot = value;
          break;
      }
    }
  }

  return { width, height, states };
}

/**
 * Extract a single sprite's RGBA pixel data from the parsed DMI.
 * @param {object} dmi - Parsed DMI object from parseDmi()
 * @param {number} stateIndex - Index of the state in dmi.states
 * @param {number} dir - Direction index (0=S, 1=N, 2=E, 3=W)
 * @param {number} frame - Frame index (0-based)
 * @returns {Buffer} - RGBA pixel data (width × height × 4 bytes)
 */
function extractSprite(dmi, stateIndex, dir, frame) {
  const { spriteWidth, spriteHeight, pngWidth, png, states } = dmi;
  const cols = Math.floor(pngWidth / spriteWidth);

  // Calculate the absolute cell index by summing all preceding states' cells
  let cellIndex = 0;
  for (let i = 0; i < stateIndex; i++) {
    cellIndex += states[i].dirs * states[i].frames;
  }
  // Add offset for this specific dir+frame
  cellIndex += dir * states[stateIndex].frames + frame;

  const col = cellIndex % cols;
  const row = Math.floor(cellIndex / cols);

  const srcX = col * spriteWidth;
  const srcY = row * spriteHeight;

  // Extract RGBA pixels
  const pixels = Buffer.alloc(spriteWidth * spriteHeight * 4);
  for (let y = 0; y < spriteHeight; y++) {
    for (let x = 0; x < spriteWidth; x++) {
      const srcIdx = ((srcY + y) * pngWidth + (srcX + x)) * 4;
      const dstIdx = (y * spriteWidth + x) * 4;
      pixels[dstIdx] = png.data[srcIdx];       // R
      pixels[dstIdx + 1] = png.data[srcIdx + 1]; // G
      pixels[dstIdx + 2] = png.data[srcIdx + 2]; // B
      pixels[dstIdx + 3] = png.data[srcIdx + 3]; // A
    }
  }

  return pixels;
}

/**
 * Check if a sprite is completely empty (all pixels transparent).
 */
function isSpriteEmpty(pixels) {
  for (let i = 3; i < pixels.length; i += 4) {
    if (pixels[i] > 0) return false;
  }
  return true;
}

module.exports = {
  parseDmi,
  extractSprite,
  isSpriteEmpty,
  DIR_SOUTH,
  DIR_NORTH,
  DIR_EAST,
  DIR_WEST,
};
