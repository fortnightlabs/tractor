Tractor = require '../public/javascripts/application'

module.exports =
  'initialize': (beforeExit, assert) ->
    now = new Date
    items = new Tractor.Items [{ start: now }]
    assert.ok items instanceof Tractor.Group
