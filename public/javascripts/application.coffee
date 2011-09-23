Backbone.Model.prototype.idAttribute = '_id'

Tractor = window.Tractor = {}

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
    @bind 'add',              @updateTotals, this
    @bind 'remove',           @updateTotals, this
    @bind 'reset',            @updateTotals, this
    @bind 'change:projectId', @updateTotals, this
    @updateTotals()

  parse: (response) ->
    _.map response, Tractor.Item.prototype.parse

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
      apps[item.get('app')] = true
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
    @bind 'reset',            @updateHour, this
    @updateHour()

  updateHour: ->
    @hour = @first()?.get('start')

class Tractor.Items extends Tractor.Hour
  url: '/items'

  initialize: ->
    super *arguments
    @bind 'reset',           @resetHours, this
    @bind 'remove',          @updateCursorRemove, this
    @bind 'change:cursor',   @updateCursorChange, this
    @bind 'change:selected', @selectRange, this

  resetHours: ->
    @cursor = -1
    @hours = []
    @chain()
      .groupBy((item) -> item.get 'hour')
      .each((items, h) => @hours[h] = new Tractor.Hour items)

  atCursor: -> @at @cursor
  next: -> @at Math.min(@cursor + 1, @length - 1)
  prev: -> @at Math.max(@cursor - 1, 0)

  updateCursorChange: (model, val) ->
    return unless val
    @atCursor()?.set cursor: false unless model == @atCursor()
    @cursor = @indexOf model # TODO slow

  updateCursorRemove: (model) ->
    @cursor-- if model.get('start') <= @atCursor()?.get('start')
    @atCursor().set cursor: true

  selectRange: (model, val, options) ->
    if val and options.range
      i = @indexOf model
      for o in @models.slice(Math.min(i, @cursor), Math.max(i, @cursor))
        o.set selected: true
      true
