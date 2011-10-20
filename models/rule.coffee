_ = require 'underscore'
async = require 'async'
mongoose = require 'mongoose'
Item = mongoose.model 'Item'

RuleSchema = module.exports = new mongoose.Schema
  query:
    type: String
    required: true
  priority: Number
  project:
    type: mongoose.Schema.ObjectId
    ref: 'Project'
    required: true

# scopes

RuleSchema.namedScope 'sorted', -> @asc 'priority'

# methods

RuleSchema.method 'run', (conditions, callback) ->
  conditions.projectId = null
  Item.search(@query).update conditions,
    (projectId: @project), multi: true,
    callback

# statics

RuleSchema.static 'run', (conditions, callback) ->
  Rule.sorted.find().run (err, rules) ->
    return callback(err) if err?
    run = (rule, fn) -> rule.run conditions, fn
    async.forEachSeries rules, run, callback

Rule = mongoose.model 'Rule', RuleSchema
