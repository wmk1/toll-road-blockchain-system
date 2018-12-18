const path = require('path')

module.exports = {
  entry: {
    app: './app/scripts/index.js'
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, 'script'),
    publicPath: '/script/'
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
