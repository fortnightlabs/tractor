Backbone.Model.prototype.idAttribute = '_id'

Tractor = window.Tractor = {}

Tractor.Project = Backbone.Model.extend()

Tractor.Projects = Backbone.Collection.extend
  model: Tractor.Project
  url: '/projects'

Tractor.Item = Backbone.Model.extend
  defaults: ->
    selected: false
    cursor: false
  toggle: -> @set selected: !@get('selected')
  parse: (r) ->
    r.start = new Date r.start
    r.end = new Date r.end
    r.hour = r.start.getHours()
    r

class Tractor.Hour extends Backbone.Collection
  model: Tractor.Item
  url: '/items'

  initialize: ->
    @bind 'reset',            @updateTotals
    @bind 'add',              @updateTotals
    @bind 'remove',           @updateTotals
    @bind 'change:projectId', @updateTotals

    @updateTotals()

  parse: (response) ->
    _.map response, Tractor.Item.prototype.parse

  selected: ->
    @chain().filter (i) -> i.get 'selected'

  updateTotals: =>
    projects = {}
    totals =
      count: 0
      unassigned: 0
      projects: projects
    @each (item) ->
      totals.count++
      if project = item.get 'projectId'
        projects[project] = (projects[project] || 0) + item.get 'duration'
      else
        totals.unassigned += item.get 'duration'
    @totals = totals

class Tractor.Items extends Tractor.Hour
  initialize: ->
    super *arguments
    @bind 'change:cursor', @updateCursorChange
    @bind 'remove',        @updateCursorRemove
    @bind 'reset',         @resetHours

  resetHours: =>
    @cursor = -1
    @hours = []
    @chain()
      .groupBy((item) -> item.get 'hour')
      .each((items, h) => @hours[h] = new Tractor.Hour items)

  atCursor: -> @at @cursor
  next: -> @at Math.min(@cursor + 1, @length - 1)
  prev: -> @at Math.max(@cursor - 1, 0)

  updateCursorChange: (model, val) =>
    return unless val
    @atCursor()?.set cursor: false unless model == @atCursor()
    console.time('indexOf')
    @cursor = @indexOf model # TODO slow
    console.timeEnd('indexOf')

  updateCursorRemove: (model) =>
    @cursor-- if model.get('start') <= @atCursor()?.get('start')
    @atCursor().set cursor: true
