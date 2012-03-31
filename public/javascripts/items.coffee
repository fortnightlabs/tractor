$.fx.speeds._default = $.fx.speeds.fast = 50

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

class ItemView extends Backbone.View
  tagName: 'tr'
  template: template?._['item-view']

  events:
    'click':                      'setCursor'
    'cursor.tractor':             'setCursor'
    'click input[type=checkbox]': 'select'
    'mousedown':                  'preventSelection'

  initialize: ->
    @model.bind 'change:cursor',    @changeCursor, this
    @model.bind 'change:selected',  @changeSelected, this
    @model.bind 'destroy',          @remove, this

  remove: ->
    @model.unbind 'change:cursor',   @changeCursor
    @model.unbind 'change:selected', @changeSelected
    super arguments...

  render: ->
    attrs = @model.attributes
    tmpl = @template _.extend(Object.create(Locals), item: attrs, description: @model.description() || null)
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
    $el = $(@el).toggleClass 'cursor', val
    $.uncover($el, paddingTop: $('header').height() + 5) if val

  changeSelected: (model, val) ->
    $(@el)
      .toggleClass('selected', val)
      .find('input[type=checkbox]').prop('checked', val)

class GroupView extends Backbone.View
  tagName: 'tbody'
  template: template?._['group-view']

  events:
    'click tr.summary':                      'toggleOpen'
    'cursor.tractor tr.summary':             'setCursor'
    'click tr.summary input[type=checkbox]': 'selectAll'

  initialize: ->
    @model.bind 'change:open',     @changeOpen, this
    @model.bind 'change:selected', @changeSelected, this
    @model.collection.bind 'change:cursor', @changeCursor, this

  remove: ->
    @model.unbind 'change:open',     @changeOpen, this
    @model.unbind 'change:selected', @changeSelected, this
    @model.collection.unbind 'change:cursor', @changeCursor, this
    _.invoke @views, 'remove'
    super arguments...

  render: ->
    if @model.get 'projectId'
      @el.innerHTML = @template _.extend(Object.create(Locals), group: @model)
      @el.className = 'assigned'
    else
      @views = @model.collection.map (i) ->
        v = new ItemView model: i
        @el.appendChild v.render().el
        v
      , this
    this

  toggleOpen: ->
    @model.set open: !@model.get('open')
    @setCursor()

  setCursor: ->
    @model.collection.first().set cursor: true

  selectAll: (e) ->
    e.stopPropagation()
    @model.collection.invoke 'set', selected: e.target.checked

  changeOpen: (group, val) ->
    if val
      @views ||= @model.collection.map (i) -> new ItemView model: i
      @el.appendChild v.render().el for v in @views
      @$('tr.summary').removeClass 'cursor'
    else
      _.invoke @views, 'detach'
      @$('tr.summary').addClass 'cursor' if @model.get('cursor')

  changeCursor: (item, val) ->
    if not @model.get 'open'
      summary = @$('tr.summary').toggleClass 'cursor', val
      $.uncover(summary, paddingTop: $('header').height() + 5) if val

  changeSelected: (model, val) ->
    @$('tr.summary input[type=checkbox]').prop 'checked', @model.get('selected')

class TotalsView extends Backbone.View
  tagName: 'thead'
  template: template?._['totals-view']

  initialize: ->
    @collection.bind 'change:totals', @render, this

  render: ->
    @el.innerHTML = @template _.extend(Object.create(Locals), totals: @collection.totals)
    this

class HourView extends Backbone.View
  tagName: 'li'
  template: template?._['hour-view']
  events:
    'click thead input[type=checkbox]': 'selectAll'

  initialize: ->
    @collection.bind 'change:totals',    @changeTotals, this
    @collection.bind 'change:projectId', @render, this

  render: ->
    @el.innerHTML = @template _.extend(Object.create(Locals), hour: @collection)
    table = @$('table')
    table.append new TotalsView(collection: @collection).render().el
    _.invoke @views, 'remove'
    @views = @collection.map (g) ->
      v = new GroupView model: g
      table.append v.render().el
      v
    this

  selectAll: (e) ->
    # TODO speed up
    e.stopPropagation()
    _.invoke @collection.items(), 'set', selected: e.target.checked

  changeTotals: (model, val) ->
    @$('th.project').text Locals.toDurationString(@collection.totals.selected) || 'project'
    @$('thead input[type=checkbox]').prop 'checked', @collection.selected

class InfoView extends Backbone.View
  el: 'aside'
  template: template?._['info-view']

  initialize: ->
    @collection.bind 'change:cursor', @render, this

  render: (item, cursor) ->
    aside = @template _.extend(Object.create(Locals), item: item)
    @el.innerHTML = $(aside).html()
    this

class ItemList extends Backbone.View
  el: 'body'

  initialize: ->
    @router = @options.router
    @collection.bind 'reset',         @reset, this
    @collection.bind 'change:totals', @changeTotals, this
    @info = new InfoView collection: @collection
    @$('input[type=date]').datepicker
      dateFormat: 'yy-mm-dd'
      selectOtherMonths: true
      showOtherMonths: true

  events:
    'keylisten':                           'keylisten'
    'submit form#filter':                  'filter'
    'change input[type=date]':             'filter'
    'click .totals dt':                    'filterProject'
    'search input[name=query]':            'clearSearch'
    'click .toolbar input[type=checkbox]': 'selectAll'
    'search input[name=match]':            'selectMatch'
    'change select#projects':              'assign'
    'click button#destroy':                'destroy'

  reset: ->
    list = @$ 'ul.items'
    list.html null
    _.each @collection.hours, (hour) ->
      list.append new HourView(collection: hour).render().el
    , this
    @weekday = strftime '%a', @collection.first()?.get('start')
    @$('.toolbar th.project').text @weekday
    @$('.toolbar input[type=checkbox]').prop 'checked', false
    @$('.toolbar select#projects').prop 'selectedIndex', 0
    @$('.toolbar input[type=date]').val(strftime('%Y-%m-%d', date)) if date = @collection.first()?.get('start')
    @$(':focus').blur()

  changeTotals: ->
    tmpl = template?._['totals-view'](_.extend(Object.create(Locals), totals: @collection.totals))
    @$('.toolbar tfoot').html $(tmpl).html()
    t = @collection.totals
    @$('.toolbar th.project').text Locals.toDurationString(t.selected) || @weekday
    @$('.toolbar input[type=checkbox]').prop 'checked', t.duration == t.selected

  keylisten: (e) ->
    items = @collection
    handled = switch e.keyName
      when 'a'
        if @lastKey == 'shift+8'                        # select all
          items.invoke 'set', selected: true
        else if @lastKey == 'g'                         # filter none
          @filter e, ''
        else                                            # assign
          @$('select#projects').focus()
      when 'd'
        if @lastKey == 'û'                              # previous day
          @$('input[type="date"]')[0].stepDown()
          @$('input[type="date"]').change()
        else if @lastKey == 'ý'                         # next day
          @$('input[type="date"]')[0].stepUp()
          @$('input[type="date"]').change()
      when 'h', 'left'
        if @lastKey == 'shift+8'                        # select hour
          h = items.cursor().first().value().get 'hour'
          items.chain()
            .select((i) -> i.get('hour') == h)
            .invoke('set', selected: true)
        else                                            # close group
          group = items.cursor().first().value().group
          group.set(open: false) if group.get 'projectId'
      when 'j', 'down'                                  # down
        items.next().set cursor: true
      when 'shift+j', 'shift+down'                      # select + down
        items.cursor().invoke 'set', selected: true
        items.next().set cursor: true
      when 'pagedown', 'ctrl+f', 'ctrl+d'               # page down
        $trs = @$('ul.items tbody tr')
        $window = $(window)
        bottom = $window.scrollTop() + $window.height() - $trs.eq(0).height()
        next = $(_.detect($trs, (tr) -> $(tr).offset().top > bottom)).trigger('cursor.tractor')
        $window.scrollTop(next.offset().top - $('header').height() - 5) if next.length > 0
      when 'k', 'up'                                    # up
        items.prev().set cursor: true
      when 'shift+k', 'shift+up'                        # select + up
        items.cursor().invoke 'set', selected: true
        items.prev().set cursor: true
      when 'pageup', 'ctrl+b', 'ctrl+u'                 # page up
        $trs = @$('ul.items tbody tr')
        $window = $(window)
        top = $window.scrollTop() + $('header').height() - $trs.eq(0).height()
        prev = $(_.detect($trs, (tr) -> $(tr).offset().top > top)).trigger('cursor.tractor')
        $window.scrollTop prev.offset().top - $window.height() + $trs.eq(0).height()
      when 'l', 'right'                                 # open group
        group = items.cursor().first().value().group
        group.set(open: true) if group.get 'projectId'
      when 'n'
        if @lastKey == 'shift+8'                        # deselect
          items.selected().invoke 'set', selected: false
      when 'u'
        if @lastKey == 'shift+8'                        # select unassigned
          h = items.cursor().first().value().get 'hour'
          items.chain()
            .select((i) -> i.get('hour') == h and !i.get('projectId'))
            .invoke('set', selected: true)
        else if @lastKey == 'g'                         # filter unassigned
          @filter e, 'project:unassigned'
      when 'x'                                          # select
        items.cursor().invoke 'toggle'
      when 'shift+3'                                    # delete
        @destroy e
      when '/'                                          # search
        @$('input[name=match]').select()
      when 'shift+/'
        window.open 'https://github.com/fortnightlabs/tractor/blob/master/public/javascripts/items.coffee#L226'

    if handled
      e.preventDefault()
      @lastKey = null
    else
      @lastKey = e.keyName

  filter: (e, query) ->
    e.preventDefault()

    form = @$ 'form#filter'
    $('input[name="query"]', form).val(query) if query?

    @collection.fetch data: form.serialize()
    @$('ul.items').html '<li>Loading</li>'

    path = 'items'
    path += '/' + date if date = $('input[name="date"]', form).val()
    path += '/' + query if query = $('input[name="query"]', form).val()
    @router.navigate path
    @router.updateTitle date, query # TODO dry

  filterProject: (e) ->
    @filter e, "project:#{$(e.target).text()}"

  clearSearch: (e) ->
    @$('form#filter').submit() if !$(e.target).val()

  selectAll: (e) ->
    # TODO speed up
    @collection.invoke 'set', selected: e.target.checked

  selectMatch: (e) ->
    search = $(e.target).val()
    if search != ''
      match = new RegExp search, 'i'
      @collection.each (i) -> i.set selected: i.get('search').match(match)?
    @$(':focus').blur()

  assign: (e) ->
    changes =
      projectId: $(e.target).val() || null
      selected: false
    selected = @collection.selectedOrCursor()
    selected.each (i) -> i.save changes, silent: true  # need to pass new options hash each time
    @collection.trigger 'change:projectId'
    @collection.hoursFor(selected).invoke 'trigger', 'change:projectId'
    $(e.target).prop 'selectedIndex', 0
    @$(':focus').blur()

  destroy: (e) ->
    @collection.selectedOrCursor().invoke 'destroy'

class ItemRouter extends Backbone.Router
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
    @updateTitle date, query

  updateTitle: (date, query) ->
    title = 'Tractor'
    title = query + ' &mdash; ' + title if query
    title = date + ' &mdash; ' + title if date
    $('title').html(title)

$ ->
  new ItemRouter
  Backbone.history.start pushState: true
