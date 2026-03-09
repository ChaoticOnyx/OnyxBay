/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createCompiler } from "./compiler.js";
import { reloadByondCache } from "./reloader.js";

// Vite watch mode always does full rebuilds (no webpack-style HMR chunks).
const noTmp = process.argv.includes("--no-tmp");
const reloadOnce = process.argv.includes("--reload");

const setupServer = async () => {
  const compiler = await createCompiler({
    mode: "development",
    useTmpFolder: !noTmp,
  });

  // One-shot: just copy current bundles to BYOND cache and exit
  if (reloadOnce) {
    await reloadByondCache(compiler.bundleDir);
    return;
  }

  // Normal: watch for changes and keep reloading
  await compiler.watch();
};

setupServer();
