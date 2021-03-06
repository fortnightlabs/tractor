_ = require 'underscore'
async = require 'async'

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
        Item.search(req.param('query')).onDay(req.param('date')).sorted.find (err, items) ->
          return next err if err
          res.json items

    create:
      json: (req, res, next) ->
        t0 = Date.now()
        items = req.body
        items = [ items ] unless Array.isArray items
        Item.import items, (err, i) ->
          next err if err?
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

  app.post '/items/:date?/:query?/sweep', (req, res, next) ->
    Item.search(req.param('query')).onDay(req.param('date')).sorted.find {}, ['_id', 'projectId', 'duration'], (err, items) ->
      return next(err) if err?

      # assign all unassigned items that take less than 30s into the
      # succedding item's project
      sweeps = {}
      for item in items
        if (pid = item.projectId)
          if toSweep?.length
            a = (sweeps[pid] or= [])
            a.push.apply a, toSweep
          toSweep = []
        else if item.duration > 30
          toSweep = []
        else if toSweep?
          toSweep.push item.id

      # convert to object ids
      oid = require('mongoose').Types.ObjectId.createFromHexString
      sweeps = for k, v of sweeps
        { ids: (oid(i) for i in v), projectId: oid(k) }

      for set in sweeps
        console.log 'Sweeping %d items into %s', set.ids.length, set.projectId

      async.forEach sweeps, ({projectId, ids}, fn) ->
          Item.update (_id: ($in: ids)), (projectId: projectId), multi: true, fn
        , (err) ->
          return next err if err?
          if req.format is 'json'
            res.send sweeps
          else
            res.redirect 'back'

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
