util = require 'util'
express = require 'express'
env = require './environment'

app = module.exports = express.createServer()

# db
app.db = require("#{env.paths.root}/models")(env.mongo_url)

# hacks and utils
require("#{env.paths.lib}/mongo-log")(app.db.mongo)
require("#{env.paths.lib}/strftime")

# configuration
app.configure ->
  stylus = require 'stylus'

  app.use stylus.middleware
    src: env.paths.public
    dest: env.paths.public
    compress: true
  app.use express.static(env.paths.public)
  app.use express.logger()

  app.set 'view engine', 'jade'

# routes
require("#{env.paths.root}/controllers")(app)

app.start = ->
  app.listen env.port
  util.log "Listening on 0.0.0.0:#{env.port}"
