util = require 'util'
express = require 'express'
env = require './environment'

app = express.createServer()

# configuration
app.configure ->
  app.use express.static(env.paths.public)
  app.use express.logger()
  app.set 'view engine', 'jade'

# routes
require('../controllers')(app)

app.listen env.port
util.log "Listening on 0.0.0.0:#{env.port}"

# db
app.db = require('../models')(env.mongo_url)
