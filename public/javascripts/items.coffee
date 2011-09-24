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
    @model.bind 'change:cursor',    @changeCursor, this
    @model.bind 'change:selected',  @changeSelected, this
    #@model.bind 'change:projectId', @changeProjectId, this
    @model.bind 'destroy',          @remove, this

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

  changeProjectId: (model, val) ->
    @$('td.project').text Projects.get(val).get('name')

GroupView = Backbone.View.extend
  tagName: 'tbody'
  className: 'group'
  template: template._['group-view']

  events:
    'click tr.summary input[type=checkbox]': 'selectAll'
    'click tr.summary':                      'toggle'

  initialize: ->
    @collection.bind 'group:open',      @open, this
    @collection.bind 'group:close',     @close, this
    @collection.bind 'change:cursor',   @changeCursor, this
    @collection.bind 'change:selected', @changeSelected, this
    @el.innerHTML = @template _.extend(Object.create(Locals), group: @collection)
    @open = false

  render: ->
    if @open
      @views ||= @collection.map (i) -> new ItemView model: i
      @el.appendChild v.render().el for v in @views
    else
      _.invoke @views, 'detach'
    this

  open: ->
    @open = true
    @render()

  close: ->
    @open = false
    @render()

  toggle: ->
    @open = !@open
    @render()

  selectAll: (e) ->
    e.stopPropagation()
    @collection.invoke 'set', selected: e.target.checked

  changeCursor: (model, val) ->
    if !@open
      @$('tr.summary').toggleClass 'cursor', val

  changeSelected: (model, val) ->
    allSelected = @collection.all (i) -> i.get('selected')
    @$('tr.summary input[type=checkbox]').prop 'checked', allSelected

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
    @collection.bind 'reset',            @reset, this
    @collection.bind 'change:projectId', @reset, this
    @collection.bind 'change:selected',  @changeSelected, this

  render: ->
    @el.innerHTML = @template _.extend(Object.create(Locals), hour: @collection)
    this

  reset: ->
    table = @render().$('table')

    lastGroup = lastProject = null
    @collection.each (i) ->
      project = i.get 'projectId'
      if project
        if project == lastProject
          lastGroup.add i, silent: true
        else
          if lastProject
            table.append new GroupView(collection: lastGroup.trigger('reset')).el
          lastGroup = new Tractor.Group [ i ]
          lastProject = project
      else
        if lastProject
          table.append new GroupView(collection: lastGroup.trigger('reset')).el
          lastGroup = lastProject = null
        table.append $('<tbody>').append(new ItemView(model: i).render().el)
    if lastProject
      table.append new GroupView(collection: lastGroup.trigger('reset')).el

    table.append new TotalsView(collection: @collection).render().el
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
    @collection.bind 'change:totals', @updateTotals, this

  events:
    'keylisten':              'keylisten'
    'submit form#filter':     'filter'
    'click .toolbar input[type=checkbox]': 'selectAll'
    'change select#projects': 'label'
    'click button#destroy':   'destroy'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    @hours = _.map @collection.hours, (hour) ->
      view = new HourView collection: hour
      list.append view.reset().el
      view
    , this
    @$('input[type=date]').val (i, old) =>
      old || strftime('%Y-%m-%d', @collection.first()?.get('start'))
    @$(':focus').blur()

  updateTotals: ->
    tmpl = template._['totals-view'](_.extend(Object.create(Locals), totals: @collection.totals))
    @$('table.toolbar tfoot').html $(tmpl).html()

  keylisten: (e) ->
    items = @collection
    handled = switch e.keyName
      when 'h', 'left'
        items.atCursor().trigger 'group:close'
      when 'j', 'down'
        items.next().set cursor: true
      when 'k', 'up'
        items.prev().set cursor: true
      when 'l', 'right'
        items.atCursor().trigger 'group:open'
      when 'p'
        @$('select#projects').focus()
      when 'x'
        items.atCursor().toggle()
      when 'y'
        items.selected().invoke 'destroy'
      when '/'
        @$('input[type=search]').select()
    e.preventDefault() if handled

  filter: (e) ->
    e.preventDefault()
    @collection.fetch data: $(e.target).serialize()

  selectAll: (e) ->
    @collection.invoke 'set', selected: true

  label: (e) ->
    changes =
      projectId: $(e.target).val()
      selected: false
    selected = @collection.selected()
    selected.each (i) -> i.save changes, silent: true  # need to pass new options hash each time
    @collection.trigger 'change:projectId'
    @collection.hoursFor(selected).invoke 'trigger', 'change:projectId'
    $(e.target).prop 'selectedIndex', 0

  destroy: (e) ->
    @collection.selected().invoke 'destroy'

$ ->
  Projects.fetch()

  Items = new Tractor.Items
  Items.fetch data: location.search.substring(1)

  new ItemList collection: Items
