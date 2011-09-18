util = require 'util'
express = require 'express'
env = require './environment'

app = module.exports = express.createServer()

# db
app.db = require("#{env.paths.root}/models")(env.mongo_url)

# hacks and utils
require("#{env.paths.lib}/mongo-log")(app.db.mongo)
#require("#{env.paths.lib}/strftime")
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
        'vendor/json2.js'
        'vendor/underscore.js'
        'vendor/backbone.js'
        'vendor/jquery.keylisten.js'
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
  app.use express.logger()

  app.set 'view engine', 'jade'

  app.locals
    assetManager: assetManager
  app.dynamicHelpers
    req: (req, res) -> req

# routes
require("#{env.paths.root}/controllers")(app)

app.start = ->
  app.listen env.port
  util.log "Listening on 0.0.0.0:#{env.port}"
