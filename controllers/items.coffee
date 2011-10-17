_ = require 'underscore'

module.exports = (app) ->
  Item = app.db.model 'Item'
  Project = app.db.model 'Project'

  Resource =
    index:
      html: (req, res) ->
        Project.find {}, {}, { sort: 'name' }, (err, projects) ->
          return next err if err
          res.render2 'items', projects: projects

      json: (req, res, next) ->
        today = new Date
        day = Date.parse(req.param('date') || "#{today.getFullYear()}-#{today.getMonth()+1}-#{today.getDate()}")
        nextDay = day + 86400000
        conditions = { start: { $gt: day }, end: { $lt: nextDay } }
        Item.search req.param('query'), conditions, (err, items) ->
          return next err if err
          res.json items

    create:
      json: (req, res, next) ->
        t0 = Date.now()
        items = req.body
        items = [ items ] unless Array.isArray items
        n = items.length
        i = 0
        for item in items
          Item.create item, (err, item) ->
            if err then console.log 'create error:', err else ++i
            if --n == 0
              res.json
                received: items.length
                inserted: i
                took: Date.now() - t0

    update:
      json: (req, res) ->
        item = req.item
        _.extend item, req.body
        item.save (err, item) ->
          return next err if err
          res.json item

    destroy: (req, res) ->
      req.item.remove (err) ->
        return next err if err
        res.json err, 200

    load: (id, fn) -> Item.findById id, fn

  app.resource 'items', Resource

  app.get '/items/:date?/:query?', Resource.index.html

  app.put '/items', (req, res) ->
    items = req.body || []
    items = [ items ] unless Array.isArray items
    res.send 'not implemented'

  app.delete '/items', (req, res, next) ->
    items = req.body || []
    items = [ items ] unless Array.isArray items
    ids = _.pluck items, '_id'
    Item.remove _id: { $in: ids }, (err, n) ->
      return next err if err
      res.json removed: n
