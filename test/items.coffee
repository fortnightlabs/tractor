Tractor = require '../public/javascripts/application'

newItems = ->
  new Tractor.Items [
    { duration: 30 }
    { duration: 60 }
  ]

module.exports =

  'initial updateTotals': (beforeExit, assert) ->
    items = newItems()
    assert.eql 2, items.totals.length
    assert.eql 90, items.totals.duration
    assert.eql 90, items.totals.projects.unassigned

  'add updateTotals': (beforeExit, assert) ->
    items = new Tractor.Items

    assert.eql 0, items.totals.length

    items.add new Tractor.Item(duration: 30, app: 'WebKit')
    assert.eql 1, items.totals.length
    assert.eql 30, items.totals.projects.unassigned
    assert.eql {'WebKit': true}, items.totals.apps

    items.add new Tractor.Item(duration: 60, projectId: 1)
    assert.eql 2, items.totals.length
    assert.eql 30, items.totals.projects.unassigned
    assert.eql 60, items.totals.projects[1]
    assert.eql {'WebKit': true}, items.totals.apps

  'remove updateTotals': (beforeExit, assert) ->
    items = newItems()
    items.remove items.last()
    assert.eql 1, items.totals.length
    assert.eql 30, items.totals.projects.unassigned

  'change:projectId updateTotals': (beforeExit, assert) ->
    items = newItems()
    items.last().set projectId: 1
    assert.eql 30, items.totals.projects.unassigned
    assert.eql 60, items.totals.projects[1]

  'updateTotals triggers change:totals': (beforeExit, assert) ->
    items = newItems()
    n = 0
    items.bind 'change:totals', -> ++n
    items.updateTotals()
    assert.eql 1, n

  'selected': (beforeExit, assert) ->
    items = newItems()
    assert.eql 0, items.selected().size().value()
    items.first().set selected: true
    assert.eql 1, items.selected().size().value()
    assert.equal items.first(), items.selected().first().value()
