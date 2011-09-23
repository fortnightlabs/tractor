mongoose = require 'mongoose'

Project = mongoose.model 'Project'

ItemSchema = module.exports = new mongoose.Schema
  start:
    type: Date
    required: true
    validate: [ ((d) -> d > 0), 'min' ]
  end:
    type: Date
    required: true
    validate: [ ((d) -> d > 0), 'min' ]
  duration: Number
  app: String
  info: {}
  projectId: mongoose.Schema.ObjectId

ItemSchema.pre 'save', (next) ->
  @duration = (@end - @start) / 1000
  unless @duration > 0
    @invalidate 'duration', 'min'
    return next @_validationError
  next()

Item = mongoose.model 'Item', ItemSchema
