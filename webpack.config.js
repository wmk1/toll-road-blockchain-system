const path = require('path')

module.exports = {
  entry: {
    app: './app/scripts/index.js'
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [{
      test: /\.css$/, // include .js files
      use: [{
        loader: 'css-loader'
      }]
    }]
  }
}
