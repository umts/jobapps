module.exports = {
  parser: 'postcss-scss',
  plugins: {
    '@csstools/postcss-sass': {includePaths: ['node_modules'], quietDeps: true},
    'autoprefixer': {},
  },
};
