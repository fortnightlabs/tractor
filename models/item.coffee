_ = require 'underscore'
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
  search: String
  projectId: mongoose.Schema.ObjectId

ItemSchema.pre 'save', (next) ->
  @duration = (@end - @start) / 1000
  unless @duration > 0
    @invalidate 'duration', 'min'
    return next @_validationError
  next()

ItemSchema.pre 'save', (next) ->
  search = [ @app ]
  if @info
    search.push @info.title
    search.push @info.sender
    search.push @info.recipients
    search.push @info.subject
  @search = _.compact(search).join '\n'
  next()

Item = mongoose.model 'Item', ItemSchema
