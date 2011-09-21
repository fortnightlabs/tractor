HourView = Backbone.View.extend
  tagName: 'li'

  initialize: ->
    @projects = @options.projects
    @collection.bind 'reset', @reset, this
    @collection.bind 'all', @render, this

  events:
    'click input[type=checkbox]': 'select'
    'click tr': 'cursor'

  reset: ->
    $(@el).html @template('hour-view', items: @collection.models)
    @render()

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

  template: (tmpl, locals) ->
    _.extend locals,
      projects: @projects
      toDurationString: @toDurationString
    template._[tmpl](locals)

  render: (e, item, val) ->
    switch e
      when 'change:selected'
        duration = @collection.selected().reduce(((sum, i) -> sum + i.get('duration')), 0).value()
        @$('th.project').text @toDurationString(duration) || 'project'
        @$('thead input[type=checkbox]').prop 'checked', false unless val
        @$("tr##{item.id}")
          .toggleClass('selected', val)
          .find('input[type=checkbox]').prop('checked', val)
      when 'change:cursor'
        @$("tr##{item.id}").toggleClass('cursor', val)
      when 'change:projectId'
        project = @projects.get val
        @$("tr##{item.id} td.project").text project.get('name')
      when 'remove'
        @$("tr##{item.id}").remove()
    @$('tr.footer').html @template('totals-view', totals: @collection.totals)
    this

ItemList = Backbone.View.extend
  el: 'body'

  initialize: ->
    @collection.bind 'reset', @reset, this
    @collection.bind 'all', @render, this

  events:
    'submit form#filter': 'filter'
    'change select#projects': 'label'
    'keylisten': 'keylisten'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    @hours = _.map @collection.hours, (hour) =>
      view = new HourView collection: hour, projects: @options.projects
      list.append view.reset().el
      view

  filter: (e) ->
    e.preventDefault()
    @collection.fetch data: $(e.target).serialize()

  label: (e) ->
    @collection.selected().invoke 'save',
      projectId: $(e.target).val()
      selected: false
    $(e.target).prop 'selectedIndex', 0

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

  render: ->
    @$('input[type=date]').val (i, old) =>
      old || strftime('%Y-%m-%d', @collection.first()?.get('start'))
    @$(':focus').blur()
    this

$ ->
  Projects = new Tractor.Projects
  Projects.fetch()

  Items = new Tractor.Items
  Items.fetch()

  new ItemList collection: Items, projects: Projects
