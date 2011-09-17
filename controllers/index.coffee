module.exports = (app) ->
  require("./#{lib}")(app) for lib in ['items']

  app.get '/', (req, res) ->
    res.render 'index/index'
