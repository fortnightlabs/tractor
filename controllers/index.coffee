module.exports = (app) ->
  require("./#{lib}")(app) for lib in ['items', 'projects']
  app.get '/', (req, res) -> res.redirect '/items'
