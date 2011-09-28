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

class Tractor.Group extends Backbone.Collection
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
      count: 0
      unassigned: 0
      apps: apps
      projects: projects
    @each (item) ->
      totals.count++
      apps[app] = true if app = item.get 'app'
      if project = item.get 'projectId'
        projects[project] = (projects[project] || 0) + item.get 'duration'
      else
        totals.unassigned += item.get 'duration'
    @totals = totals
    @trigger 'change:totals', this, @totals

  selected: ->
    @chain().filter (i) -> i.get 'selected'

class Tractor.Hour extends Tractor.Group
  initialize: ->
    super *arguments
    @hour = @first()?.get('start')

class Tractor.Items extends Tractor.Group
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
