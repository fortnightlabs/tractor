Tractor =
  if exports?
    Backbone = require './vendor/backbone'
    _ = require 'underscore'
    exports
  else  # TODO dry
    Backbone = window.Backbone
    _ = window._
    window.Tractor = {}

Backbone.Model.prototype.idAttribute = '_id'

Tractor.Project = Backbone.Model.extend()

Tractor.Projects = Backbone.Collection.extend
  model: Tractor.Project
  url: '/projects'

Tractor.Item = Backbone.Model.extend
  toggle: -> @set selected: !@get('selected')
  parse: (r) ->
    r.start = new Date r.start
    r.end = new Date r.end
    r.hour = r.start.getHours()
    r

class Tractor.Items extends Backbone.Collection
  model: Tractor.Item

  initialize: ->
    @bind 'reset',            @updateTotals, this
    @bind 'add',              @updateTotals, this
    @bind 'remove',           @updateTotals, this
    @bind 'change:projectId', @updateTotals, this
    @updateTotals()

  updateTotals: ->
    projects = {}
    apps = {}
    totals =
      length: @length
      duration: 0
      apps: apps
      projects: projects
    @each (item) ->
      totals.duration += duration = item.get 'duration'
      apps[app] = true if app = item.get 'app'
      project = item.get('projectId') || 'unassigned'
      projects[project] = (projects[project] || 0) + duration
    @totals = totals
    @trigger 'change:totals', this, @totals

  selected: ->
    @chain().filter (i) -> i.get 'selected'

class Tractor.Group extends Backbone.Model
  defaults:
    open: false

  initialize: ->
    @collection = new Tractor.Items
    @collection.bind 'all', @trigger, this
    @collection.bind 'add', @resetAttributes, this
    @collection.bind 'remove', @resetAttributes, this
    @collection.bind 'change:selected', @resetAttributes, this

  add: -> @collection.add.apply @collection, arguments

  resetAttributes: ->
    @set
      projectId: @collection.first()?.get('projectId')
      start: @collection.first()?.get('start')
      end: @collection.last()?.get('end')
      selected: @collection.all (i) -> i.get 'selected'
      duration: @collection.totals.duration

class Tractor.Hour extends Backbone.Collection
  model: Tractor.Group

  initialize: (models, options) ->
    @bind 'change:projectId', @resetGroups, this
    @hour = @first()?.get('start')
    @resetGroups()
    @updateTotals()

  items: ->
    if @length is 0 or @first() instanceof Tractor.Item
      @models
    else
      @reduce (r, group) ->
        r.concat group.collection.models
      , []

  resetGroups: ->
    groups = []
    lastProjectId = lastGroup = null
    _.each @items(), (i) ->
      projectId = i.get('projectId') || null
      if not lastGroup or projectId isnt lastProjectId
        lastGroup = new Tractor.Group
        groups.push lastGroup
        lastProjectId = projectId
      lastGroup.add i, silent: true
    , this

    _.invoke groups, 'resetAttributes'
    @reset groups

  updateTotals: ->
    projects = {}
    apps = {}
    totals =
      length: 0
      duration: 0
      apps: apps
      projects: projects
    @totals = totals

class Tractor.AllItems extends Tractor.Items
  url: '/items'
  parse: (response) ->
    _.map response, Tractor.Item.prototype.parse

  initialize: ->
    super *arguments
    @bind 'reset',           @resetHours, this
    @bind 'remove',          @updateCursorRemove, this
    @bind 'change:cursor',   @updateCursorChange, this
    @bind 'change:selected', @selectRange, this

  resetHours: ->
    @_cursor = [0, 0]
    @at(0)?.set { cursor: true }, { silent: true }
    @hours = []
    @chain()
      .groupBy((item) -> item.get 'hour')
      .each((items, h) => @hours[h] = new Tractor.Hour items)

  hoursFor: (items) ->
    hours = items.invoke('get', 'hour').uniq().value()
    _(@hours[h] for h in hours)

  cursor: -> _(@models[@_cursor[0] .. @_cursor[1]]).chain()
  next: -> @at Math.min(@_cursor[1] + 1, @length - 1)
  prev: -> @at Math.max(@_cursor[0] - 1, 0)

  updateCursorChange: (model, val, options) ->
    return unless val
    if val and !options.multiple
      @cursor().without(model).invoke 'set', cursor: false
    index = @indexOf model # TODO slow
    @_cursor =
      if options.multiple
        [ Math.min(@_cursor[0], index), Math.max(@_cursor[1], index) ]
      else
        [ index, index ]

  updateCursorRemove: (model) ->
    return
    if model.get('start') <= @at(@_cursor[0]).get('start')
      @_cursor[0]--
      @_cursor[1]--
    @cursor().invoke 'set', cursor: true

  selectRange: (model, val, options) ->
    if val and options.range
      i = @indexOf model
      for o in @models.slice(Math.min(i, @cursor), Math.max(i, @cursor))
        o.set selected: true
      true
