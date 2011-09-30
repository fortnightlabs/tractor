Tractor = require '../public/javascripts/application'

newGroup = (items...) ->
  new Tractor.Group collection: items

module.exports =
  'initialize with collection': (beforeExit, assert) ->
    item = new Tractor.Item
    group = newGroup item

    assert.equal item, group.collection.models[0]
    assert.equal group, item.group

  'echos change:projectId on items': (beforeExit, assert) ->
    item = new Tractor.Item
    group = newGroup item

    n = 0
    group.bind 'change:projectId', -> n++
    item.set projectId: 2
    assert.eql 1, n

  'maintains the start time': (beforeExit, assert) ->
    now = new Date
    item = new Tractor.Item start: now
    group = newGroup item

    assert.eql now, group.get('start')

  'opening a group sets cursor to first': (beforeExit, assert) ->
    group = newGroup [ new Tractor.Item, new Tractor.Item ]

  'closing a group sets cursor to first': (beforeExit, assert) ->
    group = newGroup [ new Tractor.Item, new Tractor.Item ]
