import { defineConfig } from "vite";
import { resolve } from "path";
import { pathToFileURL } from "url";
import { createRequire } from "module";
import babel from "@rollup/plugin-babel";

const entry = process.env.VITE_ENTRY || "all";

function spriteAtlasPlugin() {
  return {
    name: "sprite-atlas",
    buildStart() {
      // Opt-out via env (set by build.js --skip-atlas)
      if (process.env.SKIP_ATLAS === "true") return;
      const force = process.env.FORCE_ATLAS === "true";

      try {
        const req = createRequire(import.meta.url);
        const { needsRebuild, buildAtlases } = req("./tools/build-atlas.js");

        if (force || needsRebuild()) {
          console.log("\n🎨 Rebuilding sprite atlas...");
          const start = Date.now();
          buildAtlases();
          const elapsed = ((Date.now() - start) / 1000).toFixed(1);
          console.log(`🎨 Atlas built in ${elapsed}s\n`);
        } else {
          console.log("🎨 Sprite atlas is up to date.");
        }
      } catch (e) {
        // Gracefully skip if icons dir missing, pngjs not installed, etc.
        console.warn(`⚠️  Sprite atlas build skipped: ${e.message}`);
      }
    },
  };
}

export default defineConfig(({ command, mode }) => {
  const isProduction = mode === "production";
  const useTmpFolder = process.env.VITE_USE_TMP === "true";
  const outDir = resolve(__dirname, useTmpFolder ? "public/.tmp" : "public");

  const baseConfig = {
    root: resolve(__dirname),
    esbuild: false,
    plugins: [
      spriteAtlasPlugin(),
      babel({
        babelHelpers: "bundled",
        include: ["packages/**/*.{js,jsx,ts,tsx}"],
        exclude: "node_modules/**",
        extensions: [".js", ".jsx", ".ts", ".tsx"],
        presets: [
          [
            "@babel/preset-typescript",
            {
              allowDeclareFields: true,
              isTSX: true,
              allExtensions: true,
            },
          ],
        ],
        plugins: [
          "babel-plugin-inferno",
          resolve(__dirname, "packages/common/string.babel-plugin.cjs"),
          ...(isProduction ? ["babel-plugin-transform-remove-console"] : []),
        ],
      }),
    ],
    resolve: {
      extensions: [".tsx", ".ts", ".jsx", ".js"],
      alias: {
        common: resolve(__dirname, "packages/common"),
        tgui: resolve(__dirname, "packages/tgui"),
        "tgui-panel": resolve(__dirname, "packages/tgui-panel"),
        assets: resolve(__dirname, "packages/tgui/assets"),
      },
    },
    css: {
      devSourcemap: !isProduction,
      preprocessorOptions: {
        scss: {
          importers: [
            {
              findFileUrl(url) {
                if (url.startsWith("~")) {
                  const cleanUrl = url.slice(1);

                  const aliasMap = {
                    "tgui/": "packages/tgui/",
                    "tgui-panel/": "packages/tgui-panel/",
                    "common/": "packages/common/",
                  };

                  for (const [alias, realPath] of Object.entries(aliasMap)) {
                    if (cleanUrl.startsWith(alias)) {
                      const filePath = cleanUrl.replace(alias, realPath);
                      return pathToFileURL(resolve(__dirname, filePath));
                    }
                  }

                  return pathToFileURL(
                    resolve(__dirname, "packages", cleanUrl),
                  );
                }
                return null;
              },
            },
          ],
        },
      },
    },
    assetsInclude: ["**/*.png", "**/*.jpg", "**/*.svg", "**/*.gif"],
    define: {
      "process.env.NODE_ENV": JSON.stringify(mode),
      "process.env.DEV_SERVER_IP": JSON.stringify(
        process.env.DEV_SERVER_IP || null,
      ),
    },
    server: {
      port: 3000,
      hmr: true,
    },
  };

  const createBuildConfig = (entryName, entryPath) => ({
    ...baseConfig,
    build: {
      outDir,
      emptyOutDir: false,
      sourcemap: isProduction ? false : "inline",
      minify: isProduction ? "terser" : false,
      target: "esnext",
      cssCodeSplit: false,
      chunkSizeWarningLimit: 1000,
      assetsInlineLimit: 100000,
      terserOptions: isProduction
        ? {
            format: {
              comments: false,
              ascii_only: true,
            },
          }
        : undefined,

      rollupOptions: {
        input: entryPath,
        output: {
          dir: outDir,
          entryFileNames: `${entryName}.bundle.js`,
          assetFileNames: `${entryName}.bundle[extname]`,
          format: "iife",
          inlineDynamicImports: true,
        },
      },
    },
  });

  if (entry === "tgui") {
    return createBuildConfig(
      "tgui",
      resolve(__dirname, "packages/tgui/index.tsx"),
    );
  }

  if (entry === "tgui-panel") {
    return createBuildConfig(
      "tgui-panel",
      resolve(__dirname, "packages/tgui-panel/index.tsx"),
    );
  }

  return {
    ...baseConfig,
    build: {
      outDir,
      emptyOutDir: false,
      sourcemap: isProduction ? false : "inline",
      minify: isProduction ? "terser" : false,
      target: "esnext",
      cssCodeSplit: true,
      assetsInlineLimit: 100000,
      terserOptions: isProduction
        ? {
            format: {
              comments: false,
              ascii_only: true,
            },
          }
        : undefined,
      rollupOptions: {
        input: {
          tgui: resolve(__dirname, "packages/tgui/index.tsx"),
          "tgui-panel": resolve(__dirname, "packages/tgui-panel/index.tsx"),
        },
        output: {
          dir: outDir,
          entryFileNames: "[name].bundle.js",
          chunkFileNames: "[name].chunk.js",
          assetFileNames: "[name].bundle[extname]",
          format: "es",
        },
      },
    },
  };
});
