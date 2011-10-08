module.exports = (app) ->
  for lib in ['items', 'projects', 'rules']
    require("./#{lib}")(app)

  app.get '/', (req, res) -> res.redirect '/items'
