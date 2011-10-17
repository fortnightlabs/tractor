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

RuleSchema.method 'apply', (conditions, callback) ->
  query = Item.search(@query, conditions)
  query.options.multi = true
  query.update projectId: @project, callback

Rule = mongoose.model 'Rule', RuleSchema
