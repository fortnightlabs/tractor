module.exports = (app) ->
  Item = app.db.model 'Item'

  app.get '/items(/:date)?', (req, res) ->
    day = Date.parse req.params.date
    day = Date.now() if isNaN(day)
    nextDay = day + 86400000
    conditions = { start: { $gt: day }, end: { $lt: nextDay } }
    Item.find conditions, {}, { sort: 'start' }, (err, items) ->
      return next err if err
      byHour = []
      items.forEach (i) ->
        hour = i.start.getHours()
        (byHour[hour] ||= []).push i
      res.render 'items', items: items, byHour: byHour
