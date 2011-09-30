Tractor = require '../public/javascripts/application'

newItems = ->
  items = new Tractor.AllItems
  items.reset [
    { start: new Date(2011, 0, 1, 0, 0, 0), hour: 0 }

    # a run of unassigned
    { start: new Date(2011, 0, 1, 1, 0, 0), hour: 1 }
    { start: new Date(2011, 0, 1, 1, 0, 1), hour: 1 }

    # a run of assigned
    { start: new Date(2011, 0, 1, 1, 1, 0), hour: 1, projectId: 1 }
    { start: new Date(2011, 0, 1, 1, 2, 0), hour: 1, projectId: 1 }
  ]

module.exports =
  'resetHours': (beforeExit, assert) ->
    items = newItems()
    assert.eql 1, items.hours[0].length
    assert.eql 2, items.hours[1].length

  'cursor set unsets others': (beforeExit, assert) ->
    items = newItems()
    assert.eql items.models[0 .. 0], items.cursor().value()
    items.at(1).set cursor: true
    assert.eql items.models[1 .. 1], items.cursor().value()

  'cursor into a group sets multiple': (beforeExit, assert) ->
    items = newItems()
    items.at(3).set cursor: true
    assert.eql items.models[3 .. 4], items.cursor().value()
