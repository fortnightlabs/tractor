Tractor = require '../public/javascripts/application'

item = new Tractor.Item

module.exports =
  'parse': (beforeExit, assert) ->
    start = new Date(2011, 0, 1, 0, 0, 0)
    end = new Date(2011, 0, 1, 1, 0, 0)
    json =
      start: +start
      end: +end
      app: 'npm'
    obj = item.parse json

    assert.eql obj,
      start: start
      end: end
      hour: 0
      app: 'npm'

  'toggle': (beforeExit, assert) ->
    assert.eql undefined, item.get('selected')
    item.toggle()
    assert.eql true, item.get('selected')
    item.toggle()
    assert.eql false, item.get('selected')
