export default {
  ignoreFiles: [
    "app/assets/builds/*",
    "coverage/**/*",
    "node_modules/**/*",
    "public/assets/**/*",
    "vendor/**/*",
  ],
  extends: "stylelint-config-standard",
  overrides: [
    {
      files: ["**/*.scss"],
      extends: "stylelint-config-standard-scss",
    },
  ],
};
