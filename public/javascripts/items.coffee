HourView = Backbone.View.extend
  tagName: 'li'
  template: template._['hour-view']

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'all', @render, this

  events:
    'click input[type=checkbox]': 'select'
    'click tr': 'cursor'

  reset: ->
    $(@el).html @template(items: @collection.models, toDurationString: @toDurationString)
    this

  itemFor: (e) ->
    if id = $(e.target).closest('tr').prop('id')
      @collection.get id

  select: (e) ->
    target = $ e.target
    checked = target.prop 'checked'
    if item = @itemFor(e)
      item.set selected: checked
    else
      @collection.each (item) -> item.set selected: checked

  cursor: (e) ->
    if item = @itemFor(e)
      item.set cursor: true

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
        @$("tr##{item.id}")
          .toggleClass('selected', item.get('selected'))
          .find('input[type=checkbox]').prop('checked', item.get('selected'))
      when 'change:cursor'
        @$("tr##{item.id}").toggleClass('cursor', item.get('cursor'))
      when 'remove'
        @$("tr##{item.id}").remove()
    this

ItemList = Backbone.View.extend
  el: 'body'

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'all', @render, this

  events:
    'submit form#filter': 'filter'
    'keylisten': 'keylisten'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    @hours = _.map @collection.hours, (hour) ->
      view = new HourView collection: hour
      list.append view.reset().el
      view

  filter: (e) ->
    e.preventDefault()
    @collection.fetch data: $(e.target).serialize()

  keylisten: (e) ->
    items = @collection
    switch e.keyName
      when 'j'
        items.next().set cursor: true
      when 'k'
        items.prev().set cursor: true
      when 'x'
        items.atCursor().toggle()
      when 'y'
        items.selected().invoke 'destroy'
      when '/'
        e.preventDefault()
        @$('input[type=search]').focus()

  render: ->
    @$('input[type=date]').val (i, old) =>
      old || strftime('%Y-%m-%d', @collection.first()?.get('start'))
    this

$ ->
  Items = new Tractor.Items
  Items.fetch()

  new ItemList collection: Items
