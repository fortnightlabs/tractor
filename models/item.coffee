mongoose = require 'mongoose'

ItemSchema = module.exports = new mongoose.Schema
  start:
    type: Date
    required: true
  end:
    type: Date
    required: true
  duration: Number
  app:
    type: String
    required: true
  info: {}
  projectId: mongoose.Schema.ObjectId

Item = mongoose.model 'Item', ItemSchema
