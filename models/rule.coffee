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

# methods

RuleSchema.method 'run', (conditions, callback) ->
  conditions.projectId = null
  Item.search(@query).update conditions,
    (projectId: @project), multi: true,
    callback

# statics

RuleSchema.static 'run', (conditions, callback) ->
  Rule.find().asc('priority').run (err, rules) ->
    return callback(err) if err?
    run = (rule, fn) -> rule.run conditions, fn
    async.forEachSeries rules, run, callback

Rule = mongoose.model 'Rule', RuleSchema
