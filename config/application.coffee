util = require 'util'
express = require 'express'
env = require './env'
app = express.createServer()

app.listen env.port
util.log "Listening on 0.0.0.0:#{env.port}"
