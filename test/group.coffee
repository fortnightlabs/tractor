Tractor = require '../public/javascripts/application'

newGroup = (item) ->
  group = new Tractor.Group
  group.add item
  group

module.exports =
  'add': (beforeExit, assert) ->
    item = new Tractor.Item
    group = newGroup item

    assert.equal item, group.items[0]

  'echos events on items': (beforeExit, assert) ->
    item = new Tractor.Item
    group = newGroup item

    n = 0
    group.bind 'change:foo', -> n++
    item.set foo: true
    assert.eql 1, n

  'maintains the start time': (beforeExit, assert) ->
    now = new Date
    item = new Tractor.Item start: now
    group = newGroup item

    assert.eql now, group.get('start')
