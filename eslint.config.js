import js from '@eslint/js';
import {defineConfig, globalIgnores} from 'eslint/config';
import googleConfig from 'eslint-config-google';
import globals from 'globals';

delete googleConfig.rules['valid-jsdoc'];
delete googleConfig.rules['require-jsdoc'];

export default defineConfig([
  globalIgnores([
    'app/assets/builds/*',
    'coverage/*',
    'node_modules/*',
    'public/assets/*',
  ]),
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
]);
