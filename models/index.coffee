util = require 'util'
mongoose = require 'mongoose'

require "./#{lib}" for lib in ['project']

module.exports = (url) ->
  util.log 'connecting to ' + url.cyan
  mongoose.connect url, (err) -> throw Error err if err
