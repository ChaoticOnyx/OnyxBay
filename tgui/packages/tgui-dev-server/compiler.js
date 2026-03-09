/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from "common/logging.js";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";
import { build } from "vite";
import { loadSourceMaps, setupLink } from "./link/server.js";
import { reloadByondCache } from "./reloader.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const logger = createLogger("vite");

const ROOT_DIR = resolve(__dirname, "../..");

const ENTRIES = [
  { name: "tgui", path: "packages/tgui/index.js" },
  { name: "tgui-panel", path: "packages/tgui-panel/index.js" },
];

/**
 * @param {object} options
 * @return {ViteCompiler}
 */
export const createCompiler = async (options) => {
  const compiler = new ViteCompiler();
  await compiler.setup(options);
  return compiler;
};

class ViteCompiler {
  constructor() {
    this.bundleDir = null;
    this.watchers = [];
  }

  async setup(options) {
    const useTmpFolder = options.useTmpFolder !== false;
    this.bundleDir = resolve(ROOT_DIR, useTmpFolder ? "public/.tmp" : "public");
    this.options = options;

    // Skip atlas generation in dev mode for performance.
    // Run `npm run build:atlas` manually if sprite data is needed.
    process.env.SKIP_ATLAS = "true";

    if (useTmpFolder) {
      process.env.VITE_USE_TMP = "true";
    }
  }

  async watch() {
    logger.log("setting up");

    const link = setupLink();

    // Track which entries are currently mid-build so we only
    // reload the BYOND cache once *all* entries have finished.
    const building = new Set();
    let reloadTimer = null;

    const scheduleReload = () => {
      if (reloadTimer) clearTimeout(reloadTimer);
      reloadTimer = setTimeout(async () => {
        // Guard: another build may have started while the timer was pending
        if (building.size > 0) return;
        try {
          await loadSourceMaps(this.bundleDir);
          await reloadByondCache(this.bundleDir);
          link.broadcastMessage({ type: "hotUpdate" });
        } catch (err) {
          logger.error("reload failed:", err.message || err);
        }
      }, 200);
    };

    for (const entry of ENTRIES) {
      // Pre-register so the reload waits for the initial build
      building.add(entry.name);

      process.env.VITE_ENTRY = entry.name;

      logger.log(`starting watcher: ${entry.name}`);

      const watcher = await build({
        configFile: resolve(ROOT_DIR, "vite.config.js"),
        mode: "development",
        build: { watch: {} },
        // Suppress Vite's own banner; we log everything ourselves
        logLevel: "warn",
      });

      this.watchers.push(watcher);

      watcher.on("event", (event) => {
        switch (event.code) {
          case "BUNDLE_START":
            building.add(entry.name);
            logger.log(`compiling ${entry.name}...`);
            break;

          case "BUNDLE_END":
            logger.log(`${entry.name} compiled (${event.duration}ms)`);
            // Let plugins clean up (Rollup requirement)
            if (event.result) event.result.close();
            break;

          case "END":
            building.delete(entry.name);
            scheduleReload();
            break;

          case "ERROR":
            building.delete(entry.name);
            logger.error(`${entry.name}:`, event.error?.message || event.error);
            // Still try to reload — the *other* entry may have succeeded
            scheduleReload();
            break;
        }
      });
    }

    logger.log("watching for changes");
  }

  async close() {
    for (const watcher of this.watchers) {
      await watcher.close();
    }
    this.watchers = [];
  }
}
