/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from "common/logging.js";
import fs from "fs";
import os from "os";
import { basename } from "path";
import { resolveGlob, resolvePath, normalizePath } from "./util.js";
import { regQuery } from "./winreg.js";
import { DreamSeeker } from "./dreamseeker.js";

const logger = createLogger("reloader");

// Regex pattern for bundle files
const bundlePattern = /\.(bundle|chunk|hot-update)\./;

const HOME = os.homedir();
const SEARCH_LOCATIONS = [
  // Custom location
  process.env.BYOND_CACHE,
  // Windows
  `${HOME}/*/BYOND/cache`,
  // Wine
  `${HOME}/.wine/drive_c/users/*/*/BYOND/cache`,
  // Lutris
  `${HOME}/Games/byond/drive_c/users/*/*/BYOND/cache`,
  // WSL
  "/mnt/c/Users/*/*/BYOND/cache",
];

let cacheRoot;

export const findCacheRoot = async () => {
  if (cacheRoot) {
    return cacheRoot;
  }
  logger.log("looking for byond cache");

  // Find BYOND cache folders
  for (const pattern of SEARCH_LOCATIONS) {
    if (!pattern) {
      continue;
    }
    const paths = await resolveGlob(pattern);
    if (paths.length > 0) {
      cacheRoot = paths[0];
      onCacheRootFound(cacheRoot);
      return cacheRoot;
    }
  }

  // Query the Windows Registry
  if (process.platform === "win32") {
    logger.log("querying windows registry");
    const userpath = await regQuery(
      "HKCU\\Software\\Dantom\\BYOND",
      "userpath",
    );
    if (userpath) {
      cacheRoot = `${userpath.replace(/\\$/, "").replace(/\\/g, "/")}/cache`;
      onCacheRootFound(cacheRoot);
      return cacheRoot;
    }
  }
  logger.log("found no cache directories");
};

const onCacheRootFound = (cacheRoot) => {
  logger.log(`found cache at '${cacheRoot}'`);
  // Plant a dummy browser window file, we'll be using this to avoid world topic. For BYOND 514.
  fs.closeSync(fs.openSync(`${cacheRoot}/dummy.htm`, "w"));
};

export const reloadByondCache = async (bundleDir) => {
  const cacheRoot = await findCacheRoot();
  if (!cacheRoot) {
    return;
  }

  // Find tmp folders in cache
  const cacheDirs = await resolveGlob(cacheRoot, "tmp*");
  if (cacheDirs.length === 0) {
    logger.log("found no tmp folder in cache");
    return;
  }

  // Get dreamseeker instances
  const pids = cacheDirs.map((cacheDir) => {
    const normalized = normalizePath(cacheDir);
    return parseInt(normalized.split("/cache/tmp").pop(), 10);
  });
  const dssPromise = DreamSeeker.getInstancesByPids(pids);

  // Copy assets - get all files and filter by pattern
  const allFiles = await resolveGlob(bundleDir, "*.*");
  const assets = allFiles.filter((file) => bundlePattern.test(basename(file)));

  for (const cacheDir of cacheDirs) {
    // Clear garbage - get all files and filter by pattern
    const allGarbage = await resolveGlob(cacheDir, "*.*");
    const garbage = allGarbage.filter((file) =>
      bundlePattern.test(basename(file)),
    );

    try {
      // Plant a dummy browser window file, we'll be using this to avoid world topic. For BYOND 515-516.
      fs.closeSync(fs.openSync(`${cacheDir}/dummy.htm`, "w"));

      for (const file of garbage) {
        fs.unlinkSync(file);
      }

      // Copy assets
      for (const asset of assets) {
        const destination = resolvePath(cacheDir, basename(asset));
        fs.writeFileSync(destination, fs.readFileSync(asset));
      }
      logger.log(`copied ${assets.length} files to '${cacheDir}'`);
    } catch (err) {
      logger.error(`failed copying to '${cacheDir}'`);
      logger.error(err);
    }
  }

  // Notify dreamseeker
  const dss = await dssPromise;
  if (dss.length > 0) {
    logger.log("notifying dreamseeker");
    for (const dreamseeker of dss) {
      dreamseeker.topic({
        tgui: 1,
        type: "cacheReloaded",
      });
    }
  }
};
