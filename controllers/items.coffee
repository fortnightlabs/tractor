module.exports = (app) ->
  Item = app.db.model 'Item'

  app.get '/items(/:date)?', (req, res) ->
    if req.accepts 'html'
      res.render 'items'
    else if req.accepts 'json'
      day = Date.parse req.param('date')
      day = Date.now() if isNaN(day)
      nextDay = day + 86400000
      conditions = { start: { $gt: day }, end: { $lt: nextDay } }
      Item.find conditions, {}, { sort: 'start' }, (err, items) ->
        return next err if err
        res.json items
