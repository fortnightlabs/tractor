util = require 'util'
express = require 'express'
env = require './environment'

app = module.exports = express.createServer()

# db
app.db = require("#{env.paths.root}/models")(env.mongo_url)

# hacks and utils
require("#{env.paths.lib}/mongo-log")(app.db.mongo)
#require("#{env.paths.lib}/strftime")
require 'express-resource'
require 'jadevu'

# configuration
app.configure ->
  stylus = require 'stylus'
  coffee = require 'coffee-script'
  assetManager = require('connect-assetmanager')
    js:
      route: /\/javascripts\/[a-z0-9]+\/all\.js/
      path: env.paths.public + '/javascripts/'
      dataType: 'javascript'
      debug: true
      preManipulate:
        '^': [
          (file, path, index, isLast, callback) ->
            if /\.coffee$/.test path
              callback coffee.compile(file)
            else
              callback file
        ]
      files: [ # order matters
        'polyfills.js'
        'vendor/jquery-1.6.4.js'
        'vendor/underscore.js'
        'vendor/backbone.js'
        'vendor/jquery.keylisten.js'
        'vendor/jquery.uncover.js'
        '../../node_modules/strftime/lib/index.js'
        'application.coffee'
        '*'
      ]

  app.use stylus.middleware
    src: env.paths.public
    dest: env.paths.public
    compress: true
  app.use assetManager
  app.use express.static(env.paths.public)
  app.use express.profiler()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.logger()
  app.use (req, res, next) ->
    req.format =
      if req.accepts('json') then 'json'
      else if req.accepts('html') then 'html'
    next()
  app.use app.router

  app.set 'view engine', 'jade'

  app.locals
    assetManager: assetManager
    inspect: util.inspect
  app.dynamicHelpers
    req: (req, res) -> req

# routes
require("#{env.paths.root}/controllers")(app)

app.start = ->
  app.listen env.port
  util.log "Listening on 0.0.0.0:#{env.port}"
