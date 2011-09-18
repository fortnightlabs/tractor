Backbone.Model.prototype.idAttribute = '_id'

Tractor = window.Tractor = {}

Tractor.Item = Backbone.Model.extend
  defaults: ->
    selected: false
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

  parse: (response) ->
    _.map response, Tractor.Item.prototype.parse

  reset: (models, options) ->
    @hours = []
    _(models).chain()
      .groupBy (item) ->
        item.hour
      .each (items, h) =>
        @hours[h] = new Tractor.Hour items

    Backbone.Collection.prototype.reset.apply this, arguments
