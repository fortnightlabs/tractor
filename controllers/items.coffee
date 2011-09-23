_ = require 'underscore'

module.exports = (app) ->
  Item = app.db.model 'Item'
  Project = app.db.model 'Project'

  app.resource 'items'
    index:
      html: (req, res) ->
        Project.find (err, projects) ->
          return next err if err
          res.render 'items', projects: projects

      json: (req, res, next) ->
        today = new Date(Date.now() - 86400000)
        day = Date.parse(req.param('date') || "#{today.getFullYear()}-#{today.getMonth()+1}-#{today.getDate()}")
        nextDay = day + 86400000
        conditions = { start: { $gt: day }, end: { $lt: nextDay } }
        if req.param('query')
          query = new RegExp req.param('query'), 'i'
          conditions['$or'] = [ { 'info.title': query } , { app: query } ]
        Item.find conditions, {}, { sort: 'start' }, (err, items) ->
          return next err if err
          res.json items

    create:
      json: (req, res, next) ->
        items = req.body
        items = [ items ] unless Array.isArray items
        n = items.length
        i = 0
        for item in items
          Item.create item, (err, item) ->
            ++i unless err
            res.json(received: items.length, inserted: i) if --n == 0

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
