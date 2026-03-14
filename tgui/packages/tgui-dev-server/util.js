/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from "fs";
import { resolve as resolvePath } from "path";

export { resolvePath };

/**
 * Resolve a path that may contain `*` wildcards in any segment
 * and return all matching existing paths (always forward-slash).
 */
export const resolveGlob = async (...sections) => {
  const pattern = resolvePath(...sections);
  return expandGlob(pattern);
};

function expandGlob(pattern) {
  const normalized = pattern.replace(/\\/g, "/");

  let root;
  let rest;

  if (/^[a-zA-Z]:\//.test(normalized)) {
    root = normalized.slice(0, 3);
    rest = normalized.slice(3);
  } else if (normalized.startsWith("/")) {
    root = "/";
    rest = normalized.slice(1);
  } else {
    root = ".";
    rest = normalized;
  }

  const segments = rest.split("/").filter(Boolean);
  return matchSegments([root], segments, 0);
}

function matchSegments(bases, segments, index) {
  if (index >= segments.length) {
    return bases.filter((p) => {
      try {
        fs.statSync(p);
        return true;
      } catch {
        return false;
      }
    });
  }

  const segment = segments[index];

  if (!segment.includes("*")) {
    const next = bases.map((base) => resolvePath(base, segment));
    return matchSegments(next, segments, index + 1);
  }

  const regex = segmentToRegex(segment);
  const next = [];

  for (const base of bases) {
    try {
      for (const entry of fs.readdirSync(base)) {
        if (regex.test(entry)) {
          next.push(resolvePath(base, entry));
        }
      }
    } catch {
      // Directory doesn't exist — skip
    }
  }

  return matchSegments(next, segments, index + 1);
}

function segmentToRegex(segment) {
  const escaped = segment
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replace(/\*/g, ".*");
  return new RegExp("^" + escaped + "$");
}

/**
 * Normalize a path to forward slashes.
 * Useful when comparing/splitting paths on Windows.
 */
export const normalizePath = (p) => p.replace(/\\/g, "/");
