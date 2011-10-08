mongoose = require 'mongoose'

RuleSchema = module.exports = new mongoose.Schema
  query:
    type: String
    required: true
  priority: Number
  project:
    type: mongoose.Schema.ObjectId
    ref: 'Project'
    required: true

Rule = mongoose.model 'Rule', RuleSchema
