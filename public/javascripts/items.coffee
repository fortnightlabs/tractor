Projects = new Tractor.Projects

Locals =
  projects: Projects
  toDurationString: (duration) ->
    if duration == 0
      ''
    else if duration > 3600
      (duration / 3600).toFixed(1) + 'h'
    else if duration > 60
      (duration / 60).toFixed(0) + 'm'
    else
      duration.toFixed(0) + 's'

ItemView = Backbone.View.extend
  tagName: 'tr'
  template: template._['item-view']

  events:
    'click':                      'setCursor'
    'click input[type=checkbox]': 'select'
    'mousedown':                  'preventSelection'

  initialize: ->
    #@model.bind 'change:cursor',    @changeCursor, this
    @model.bind 'change:selected',  @changeSelected, this
    #@model.bind 'destroy',          @remove, this

  render: ->
    attrs = @model.attributes
    tmpl = @template _.extend(Object.create(Locals), item: attrs)
    @el.innerHTML = tmpl.substring 4, tmpl.length-5  # get rid of <tr>
    @el.className = 'cursor' if attrs.cursor
    @el.className += ' selected' if attrs.selected
    this

  detach: ->
    $(@el).detach()

  setCursor: (e) ->
    @model.set { selected: true }, { range: true } if e.shiftKey
    @model.set cursor: true

  select: (e) ->
    @model.set selected: $(e.target).prop('checked')

  preventSelection: (e) ->
    e.preventDefault() if e.shiftKey

  changeCursor: (model, val) ->
    $el = $(@el).toggleClass('cursor', val)
    $.uncover $el if val

  changeSelected: (model, val) ->
    $(@el)
      .toggleClass('selected', val)
      .find('input[type=checkbox]').prop('checked', val)

GroupView = Backbone.View.extend
  tagName: 'tbody'
  className: 'group'
  template: template._['group-view']

  events:
    'click tr.summary': 'toggleOpen'
    'click tr.summary input[type=checkbox]': 'selectAll'

  initialize: ->
    @model.bind 'change:open',     @changeOpen, this
    #@model.bind 'change:cursor',   @changeCursor, this
    @model.bind 'change:selected', @changeSelected, this

  render: ->
    if @model.get 'projectId'
      @el.innerHTML = @template _.extend(Object.create(Locals), group: @model)
    else
      @model.collection.each (i) ->
        @el.appendChild new ItemView(model: i).render().el
      , this
    this

  toggleOpen: ->
    @model.set open: !@model.get('open')

  selectAll: (e) ->
    e.stopPropagation()
    @model.collection.invoke 'set', selected: e.target.checked

  changeOpen: ->
    if @model.get 'open'
      @views ||= @model.collection.map (i) -> new ItemView model: i
      @el.appendChild v.render().el for v in @views
    else
      _.invoke @views, 'detach'

  changeSelected: (model, val) ->
    @$('tr.summary input[type=checkbox]').prop 'checked', @model.get('selected')

TotalsView = Backbone.View.extend
  tagName: 'tfoot'
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
    @collection.bind 'change:totals',    @changeTotals, this
    @collection.bind 'change:projectId', @render, this

  render: ->
    # TODO clean up bindings?
    @el.innerHTML = @template _.extend(Object.create(Locals), hour: @collection)
    table = @$('table')
    @collection.each (g) -> table.append new GroupView(model: g).render().el
    table.append new TotalsView(collection: @collection).render().el
    this

  selectAll: (e) ->
    # TODO speed up
    _.invoke @collection.items(), 'set', selected: e.target.checked

  changeTotals: (model, val) ->
    @$('th.project').text Locals.toDurationString(@collection.totals.selected) || 'project'
    @$('thead input[type=checkbox]').prop 'checked', @collection.selected

ItemList = Backbone.View.extend
  el: 'body'

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'change:totals', @updateTotals, this
    @collection.bind 'change:selected', @changeSelected, this
    @router = @options.router

  events:
    'keylisten':              'keylisten'
    'submit form#filter':     'filter'
    'click .toolbar input[type=checkbox]': 'selectAll'
    'change select#projects': 'label'
    'click button#destroy':   'destroy'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    _.each @collection.hours, (hour) ->
      list.append new HourView(collection: hour).render().el
    , this
    @$('input[type=date]').val (i, old) =>
      old || strftime('%Y-%m-%d', @collection.first()?.get('start'))
    @$(':focus').blur()

  updateTotals: ->
    tmpl = template._['totals-view'](_.extend(Object.create(Locals), totals: @collection.totals))
    @$('table.toolbar tfoot').html $(tmpl).html()

  changeSelected: (model, val) ->
    # TODO speed up (reverse for common case speed?)
    totals = @collection.totals
    @$('.toolbar th.project').text Locals.toDurationString(totals.selected) || ''
    allSelected = totals.duration == totals.selected
    @$('.toolbar input[type=checkbox]').prop 'checked', allSelected

  keylisten: (e) ->
    items = @collection
    handled = switch e.keyName
      when 'h', 'left'
        items.cursor().first().value().trigger 'group:close'
      when 'j', 'down'
        items.next().set cursor: true
      when 'k', 'up'
        items.prev().set cursor: true
      when 'l', 'right'
        items.cursor().first().value().trigger 'group:open'
      when 'p'
        @$('select#projects').focus()
      when 'x'
        items.cursor().invoke 'toggle'
      when 'y'
        items.selected().invoke 'destroy'
      when '/'
        @$('input[type=search]').select()
    e.preventDefault() if handled

  filter: (e) ->
    e.preventDefault()
    @collection.fetch data: $(e.target).serialize()
    path = 'items'
    path += '/' + $(e.target.date).val() if $(e.target.date).val()
    path += '/' + $(e.target.query).val() if $(e.target.query).val()
    @router.navigate path

  selectAll: (e) ->
    @collection.invoke 'set', selected: e.target.checked

  label: (e) ->
    changes =
      projectId: $(e.target).val() || null
      selected: false
    selected = @collection.selected()
    selected.each (i) -> i.save changes, silent: true  # need to pass new options hash each time
    @collection.trigger 'change:projectId'
    @collection.hoursFor(selected).invoke 'trigger', 'change:projectId'
    $(e.target).prop 'selectedIndex', 0

  destroy: (e) ->
    @collection.selected().invoke 'destroy'

ItemRouter = Backbone.Router.extend
  initialize: ->
    Projects.fetch()
    @items = new Tractor.AllItems
    @view = new ItemList collection: @items, router: this

  routes:
    'items':              'fetch'
    'items/:date':        'fetch'
    'items/:date/:query': 'fetch'

  fetch: (date, query) ->
    @items.fetch data: { date: date, query: query }

$ ->
  new ItemRouter
  Backbone.history.start pushState: true
