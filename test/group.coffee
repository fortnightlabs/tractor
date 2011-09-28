Tractor = require '../public/javascripts/application'

group = ->
  new Tractor.Group [
    { duration: 30 }
    { duration: 60 }
  ]

module.exports =

  'initial updateTotals': (beforeExit, assert) ->
    g = group()
    assert.eql 2, g.totals.count
    assert.eql 90, g.totals.unassigned

  'add updateTotals': (beforeExit, assert) ->
    g = new Tractor.Group

    assert.eql 0, g.totals.count

    g.add new Tractor.Item(duration: 30, app: 'WebKit')
    assert.eql 1, g.totals.count
    assert.eql 30, g.totals.unassigned
    assert.eql {'WebKit': true}, g.totals.apps

    g.add new Tractor.Item(duration: 60, projectId: 1)
    assert.eql 2, g.totals.count
    assert.eql 30, g.totals.unassigned
    assert.eql 60, g.totals.projects[1]
    assert.eql {'WebKit': true}, g.totals.apps

  'remove updateTotals': (beforeExit, assert) ->
    g = group()
    g.remove g.last()
    assert.eql 1, g.totals.count
    assert.eql 30, g.totals.unassigned

  'change:projectId updateTotals': (beforeExit, assert) ->
    g = group()
    g.last().set projectId: 1
    assert.eql 30, g.totals.unassigned
    assert.eql 60, g.totals.projects[1]

  'updateTotals triggers change:totals': (beforeExit, assert) ->
    g = group()
    n = 0
    g.bind 'change:totals', -> ++n
    g.updateTotals()
    assert.eql 1, n

  'selected': (beforeExit, assert) ->
    g = group()
    assert.eql 0, g.selected().size().value()
    g.first().set selected: true
    assert.eql 1, g.selected().size().value()
    assert.equal g.first(), g.selected().first().value()
