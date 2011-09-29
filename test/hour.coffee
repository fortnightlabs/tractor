Tractor = require '../public/javascripts/application'

itemsForProjects = (names...) ->
  names.map (name) ->
    new Tractor.Item projectId: name

newHour = (items) ->
  new Tractor.Hour items

module.exports =
  'initialize': (beforeExit, assert) ->
    items = itemsForProjects('one', 'two')
    hour = newHour items

    assert.eql [items[0]], hour.models[0].items
    assert.eql [items[1]], hour.models[1].items

  'initialize groups correctly': (beforeExit, assert) ->
    items = itemsForProjects(1,1,2,2,3,2)
    hour = newHour items

    assert.eql [items[0], items[1]], hour.models[0].items
    assert.eql [items[2], items[3]], hour.models[1].items
    assert.eql [items[4]], hour.models[2].items
    assert.eql [items[5]], hour.models[3].items

  'recalculates groups when projectId changes': (beforeExit, assert) ->
    items = itemsForProjects(1,2,3)
    hour = newHour items
    items[1].set projectId: 1

    assert.eql [items[0], items[1]], hour.models[0].items
    assert.eql [items[2]], hour.models[1].items

  'should know its hour': (beforeExit, assert) ->
    now = new Date
    item = new Tractor.Item start: now
    hour = newHour [item]
    assert.equal now.getHours(), hour.hour
