mongoose = require 'mongoose'

Project = mongoose.model 'Project'

ItemSchema = module.exports = new mongoose.Schema
  start:
    type: Date
    required: true
  end:
    type: Date
    required: true
  duration: Number
  app: String
  info: {}
  projectId: mongoose.Schema.ObjectId

ItemSchema.pre 'save', (next) ->
  @duration = @end - @start
  next()

Item = mongoose.model 'Item', ItemSchema
