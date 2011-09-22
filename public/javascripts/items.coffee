Projects = new Tractor.Projects

Locals =
  projects: Projects
  toDurationString: (duration) ->
    if duration == 0
      ''
    else if duration > 60
      (duration / 60).toFixed(0) + ' m'
    else
      duration.toFixed(0) + ' s'

ItemView = Backbone.View.extend
  tagName: 'tr'
  template: template._['item-view']

  events:
    'click':                      'setCursor'
    'click input[type=checkbox]': 'select'

  initialize: ->
    @model.bind 'change:cursor',    @changeCursor, this
    @model.bind 'change:selected',  @changeSelected, this
    @model.bind 'change:projectId', @changeProjectId, this
    @model.bind 'destroy',          @remove, this

  render: ->
    tmpl = @template _.extend(Object.create(Locals), item: @model.attributes)
    @el.innerHTML = $(tmpl).html()
    this

  setCursor: (e) ->
    @model.set cursor: true

  select: (e) ->
    @model.set selected: $(e.target).prop('checked')

  changeCursor: (model, val) ->
    $(@el).toggleClass 'cursor', val

  changeSelected: (model, val) ->
    $(@el)
      .toggleClass('selected', val)
      .find('input[type=checkbox]').prop('checked', val)

  changeProjectId: (model, val) ->
    @$('td.project').text Projects.get(val).get('name')

  remove: ->
    $(@el).remove()

TotalsView = Backbone.View.extend
  tagName: 'tr'
  template: template._['totals-view']

  initialize: ->
    @collection.bind 'change:totals', @render, this

  render: ->
    @el.innerHTML = @template _.extend(Object.create(Locals), totals: @collection.totals)
    this

HourView = Backbone.View.extend
  tagName: 'li'
  template: template._['hour-view']
  events:
    'click thead input[type=checkbox]': 'selectAll'

  initialize: ->
    @collection.bind 'reset',           @reset, this
    @collection.bind 'change:selected', @changeSelected, this

  render: ->
    @el.innerHTML = @template _.extend(Object.create(Locals), hour: @collection)
    this

  reset: ->
    @render()
    tbody = @$('tbody')
    @collection.each (i) -> tbody.append new ItemView(model: i).render().el
    @$('tfoot').append new TotalsView(collection: @collection).render().el
    this

  selectAll: (e) ->
    @collection.invoke 'set', selected: e.target.checked

  changeSelected: (model, val) ->
    selected = @collection.selected()
    duration = selected.reduce(((sum, i) -> sum + i.get('duration')), 0).value()
    @$('th.project').text Locals.toDurationString(duration) || 'project'
    @$('thead input[type=checkbox]').prop 'checked', @collection.length == selected.value().length

ItemList = Backbone.View.extend
  el: 'body'

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'fetch', @fetch, this

  events:
    'keylisten':              'keylisten'
    'submit form#filter':     'filter'
    'change select#projects': 'label'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    console.time 'ItemList.reset'
    @hours = _.map @collection.hours, (hour) ->
      view = new HourView collection: hour
      list.append view.reset().el
      view
    , this
    console.timeEnd 'ItemList.reset'

  fetch: ->
    @$('input[type=date]').val (i, old) =>
      old || strftime('%Y-%m-%d', @collection.first()?.get('start'))
    @$(':focus').blur()

  keylisten: (e) ->
    items = @collection
    switch e.keyName
      when 'j'
        items.next().set cursor: true
      when 'k'
        items.prev().set cursor: true
      when 'l'
        @$('select#projects').focus()
      when 'x'
        items.atCursor().toggle()
      when 'y'
        items.selected().invoke 'destroy'
      when '/'
        e.preventDefault()
        @$('input[type=search]').select()

  filter: (e) ->
    e.preventDefault()
    @collection.fetch data: $(e.target).serialize()

  label: (e) ->
    @collection.selected().invoke 'save',
      projectId: $(e.target).val()
      selected: false
    $(e.target).prop 'selectedIndex', 0

$ ->
  Projects.fetch()

  Items = new Tractor.Items
  Items.fetch()

  new ItemList collection: Items
