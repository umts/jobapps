const js = require('@eslint/js');
const googleConfig = require('eslint-config-google');
const globals = require('globals');

module.exports = [
  {
    ignores: [
      'app/assets/builds/*',
      'coverage/*',
      'node_modules/*',
      'public/assets/*',
    ],
  },
  {
    files: ['**/*.js'],
    ...js.configs.recommended,
    ...googleConfig,
    rules: {
      ...js.configs.recommended.rules,
      ...googleConfig.rules,
      'max-len': ['error', {code: 120}],
    },
  },
  {
    files: ['app/assets/javascripts/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.jquery,
      },
    },
  },
  {
    files: ['*.config.js'],
    languageOptions: {
      globals: {...globals.node},
    },
  },
];
