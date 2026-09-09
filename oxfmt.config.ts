import { defineConfig } from "oxfmt";

export default defineConfig({
  $schema: "./node_modules/oxfmt/configuration_schema.json",
  ignorePatterns: [
    "app/assets/**", // TODO: Remove once de-sprocketed and work on stylesheets begins.
    "app/javascript/controllers/index.js",
    "public/400.html",
    "public/401.html",
    "public/403.html",
    "public/404.html",
    "public/406-unsupported-browser.html",
    "public/422.html",
    "public/500.html",
    "vendor/assets/**",
  ],
});
