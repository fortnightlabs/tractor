module.exports = (app) ->
  Item = app.db.model 'Item'

  app.get '/items/:date?', (req, res) ->
    if req.accepts 'html'
      res.render 'items'
    else if req.accepts 'json'
      day = Date.parse(req.param('date') || '2011-09-18')
      nextDay = day + 86400000
      conditions = { start: { $gt: day }, end: { $lt: nextDay } }
      if req.param('query')
        query = new RegExp req.param('query'), 'i'
        conditions['$or'] = [ { 'info.title': query } , { app: query } ]
      Item.find conditions, {}, { sort: 'start' }, (err, items) ->
        return next err if err
        res.json items

  app.delete '/items/:id', (req, res) ->
    Item.remove _id: req.params.id, (err) ->
      return next err if err
      res.json err, 200
