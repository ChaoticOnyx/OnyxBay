import { build } from "vite";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(__dirname, "..");

const entries = [{ name: "tgui" }, { name: "tgui-panel" }];

async function buildAll() {
  const mode = process.argv.includes("--dev") ? "development" : "production";
  const useTmpFolder = process.argv.includes("--tmp");

  // Atlas flags → forwarded to Vite plugin via env vars
  if (process.argv.includes("--skip-atlas")) {
    process.env.SKIP_ATLAS = "true";
  }
  if (process.argv.includes("--force-atlas")) {
    process.env.FORCE_ATLAS = "true";
  }

  console.log(`Building in ${mode} mode...`);

  for (const entry of entries) {
    console.log(`\nBuilding ${entry.name}...`);

    process.env.VITE_ENTRY = entry.name;
    if (useTmpFolder) {
      process.env.VITE_USE_TMP = "true";
    }

    await build({
      configFile: resolve(rootDir, "vite.config.js"),
      mode,
    });

    console.log(`✓ ${entry.name} built successfully`);

    // After the first entry builds (and atlas runs), prevent
    // the plugin from re-checking on the second entry.
    // (needsRebuild() would return false anyway thanks to cache,
    //  but this skips the file-system scan entirely.)
    process.env.SKIP_ATLAS = "true";
  }

  console.log("\n✓ All builds completed!");
}

buildAll().catch((err) => {
  console.error("Build failed:", err);
  process.exit(1);
});
