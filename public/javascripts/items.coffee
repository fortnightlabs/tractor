Projects = new Tractor.Projects

Locals =
  projects: Projects
  toDurationString: (duration) ->
    if duration == 0
      ''
    else if duration > 3600
      (duration / 3600).toFixed(1) + ' h'
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
    #@model.bind 'change:projectId', @changeProjectId, this
    @model.bind 'destroy',          @remove, this

  render: ->
    tmpl = @template _.extend(Object.create(Locals), item: @model.attributes)
    @el.innerHTML = tmpl.substring 4, tmpl.length-5  # get rid of <tr>
    @el.className = 'cursor' if @model.get('cursor')
    this

  setCursor: (e) ->
    @model.set cursor: true

  select: (e) ->
    @model.set selected: $(e.target).prop('checked')

  changeCursor: (model, val) ->
    $.uncover $(@el).toggleClass('cursor', val)

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
    'click tr.summary': 'toggle'

  initialize: ->
    @collection.bind 'change:cursor', @changeCursor, this
    @open = false

  render: ->
    unless @open
      @el.innerHTML = @template _.extend(Object.create(Locals), group: @collection)
    else
      @collection.each (i) ->
        @el.appendChild new ItemView(model: i).render().el
      , this
    this

  toggle: ->
    @open = !@open
    @render()

  changeCursor: (model, val) ->
    # open the group based on cursor presence
    if val && !@open
      @open = true
      @render()
    ### and close it when the cursor leaves
    else if !val && @collection.all((i) -> !i.get('cursor'))
      @open = false
      @render()
    ###

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
            lastGroup.trigger 'reset'
            table.append new GroupView(collection: lastGroup).render().el
          lastGroup = new Tractor.Group [ i ]
          lastProject = project
      else
        if lastProject
          lastGroup.trigger 'reset'
          table.append new GroupView(collection: lastGroup).render().el
          lastGroup = lastProject = null
        table.append $('<tbody>').append(new ItemView(model: i).render().el)
    if lastProject
      lastGroup.trigger 'reset'
      table.append new GroupView(collection: lastGroup).render().el

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
    'change select#projects': 'label'
    'click button#destroy':   'destroy'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    console.profile 'ItemList.reset'
    @hours = _.map @collection.hours, (hour) ->
      view = new HourView collection: hour
      list.append view.reset().el
      view
    , this
    console.profileEnd 'ItemList.reset'
    @$('input[type=date]').val (i, old) =>
      old || strftime('%Y-%m-%d', @collection.first()?.get('start'))
    @$(':focus').blur()

  updateTotals: ->
    tmpl = template._['totals-view'](_.extend(Object.create(Locals), totals: @collection.totals))
    @$('form#filter .totals').html $('td', tmpl).html()

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

  label: (e) ->
    @collection.selected().invoke 'save',
      projectId: $(e.target).val()
      selected: false
    $(e.target).prop 'selectedIndex', 0

  destroy: (e) ->
    @collection.selected().invoke 'destroy'

$ ->
  Projects.fetch()

  Items = new Tractor.Items
  Items.fetch()

  new ItemList collection: Items
