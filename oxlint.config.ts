import { defineConfig } from "oxlint";

export default defineConfig({
  $schema: "./node_modules/oxlint/configuration_schema.json",
  ignorePatterns: [
    // TODO: Remove once de-sprocketed.
    "app/assets/**",

    "app/javascript/controllers/index.js",
    "vendor/**",
  ],
  plugins: ["eslint", "unicorn", "oxc", "import", "promise"],
  categories: {
    correctness: "error",
    suspicious: "warn",
    pedantic: "warn",
    perf: "error",
    restriction: "error",
  },
  rules: {
    "eslint/class-methods-use-this": "off",
    "eslint/no-alert": "off",
    "eslint/no-warning-comments": "off",
    "import/no-default-export": "off",
    "import/no-unassigned-import": "off",
    "oxc/no-rest-spread-properties": "off",
    "unicorn/no-anonymous-default-export": "off",
    "unicorn/no-array-reduce": "off",
  },
});
