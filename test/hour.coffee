Tractor = require '../public/javascripts/application'

module.exports =
  'initialize': (beforeExit, assert) ->
    now = new Date
    hour = new Tractor.Hour [{ start: now }]

    assert.ok hour instanceof Tractor.Group
    assert.eql now, hour.hour
