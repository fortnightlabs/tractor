HourView = Backbone.View.extend
  tagName: 'li'
  template: template._['hour-view']

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'all', @render, this

  events:
    'click input[type=checkbox]': 'select'

  reset: ->
    $(@el).html @template(items: @collection.models, toDurationString: @toDurationString)
    this

  select: (e) ->
    target = $ e.target
    checked = target.prop 'checked'
    if id = target.closest('tr').data('id')
      item = @collection.get id
      item.set selected: checked
    else
      @collection.each (item) -> item.set selected: checked

  toDurationString: (duration) ->
    if duration == 0
      ''
    else if duration > 60
      (duration / 60).toFixed(0) + ' m'
    else
      duration.toFixed(0) + ' s'

  render: (e, item) ->
    switch e
      when 'change:selected'
        @$('th.project').html @toDurationString(@collection.duration()) || 'project'
        @$("tr[data-id=\"#{item.id}\"]")
          .toggleClass('selected', item.get('selected'))
          .find('input[type=checkbox]').prop('checked', item.get('selected'))
      when 'change:cursor'
        @$("tr[data-id=\"#{item.id}\"]").toggleClass('cursor', item.get('cursor'))
    this

ItemList = Backbone.View.extend
  el: 'body'

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'all', @render, this
    @cursor = -1

  events:
    'keylisten': 'keylisten'
    'change input[type=date]': 'changeDate'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    @hours = _.map @collection.hours, (hour) ->
      view = new HourView collection: hour
      list.append view.reset().el
      view

  keylisten: (e) ->
    items = @collection
    switch e.keyName
      when 'j'
        items.at(@cursor)?.set cursor: false
        items.at(++@cursor).set cursor: true
      when 'k'
        items.at(@cursor).set cursor: false
        items.at(--@cursor).set cursor: true
      when 'x'
        items.at(@cursor).set selected: !items.at(@cursor).get('selected')

  changeDate: (e) ->
    @collection.fetch data: date: $(e.target).val()

  render: ->
    @$('input[type=date]').val strftime('%Y-%m-%d', @collection.first()?.get('start'))
    this

$ ->
  Items = new Tractor.Items
  Items.fetch()

  new ItemList collection: Items
