import path from "node:path";
import { defineConfig } from "rolldown";

export default defineConfig({
  input: "app/javascript/application.js",
  output: {
    file: "app/assets/builds/application.js",
    format: "esm",
    sourcemap: true,
  },
  // TODO: Remove when library is published.
  resolve: {
    alias: {
      "@umts/stimulus/tom-select": path.resolve(
        import.meta.dirname,
        "./node_modules/@umts/stimulus/lib/tom-select.ts",
      ),
    },
  },
});
