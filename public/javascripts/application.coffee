Backbone.Model.prototype.idAttribute = '_id'

Tractor = window.Tractor = {}

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

Tractor.Hour = Backbone.Collection.extend
  model: Tractor.Item
  duration: ->
    @reduce (sum, item) ->
      if item.get('selected') then sum + item.get 'duration' else sum
    , 0

Tractor.Items = Backbone.Collection.extend
  model: Tractor.Item
  url: '/items'

  initialize: ->
    @bind 'all', @updateCursor, this
    @bind 'reset', @resetHours, this

  parse: (response) ->
    _.map response, Tractor.Item.prototype.parse

  selected: ->
    @chain().filter (i) -> i.get 'selected'

  atCursor: -> @at @cursor
  next: -> @at @cursor + 1
  prev: -> @at @cursor - 1

  updateCursor: (type, model, changed) ->
    switch type
      when 'change:cursor'
        return unless changed
        @atCursor()?.set cursor: false
        @cursor = @sortedIndex model, (i) -> i.get 'start'
      when 'remove'
        @cursor-- if model.get('start') <= @atCursor().get('start')

  resetHours: ->
    @cursor = -1
    @hours = []
    @chain()
      .groupBy (item) ->
        item.get 'hour'
      .each (items, h) =>
        @hours[h] = new Tractor.Hour items
