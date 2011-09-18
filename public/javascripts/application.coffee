Backbone.Model.prototype.idAttribute = '_id'

Tractor = window.Tractor = {}

Tractor.Item = Backbone.Model.extend
  defaults: ->
    selected: false
    cursor: false
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
    @bind 'reset', @resetHours, this

  parse: (response) ->
    _.map response, Tractor.Item.prototype.parse

  resetHours: ->
    @hours = []
    @chain()
      .groupBy (item) ->
        item.get 'hour'
      .each (items, h) =>
        @hours[h] = new Tractor.Hour items
