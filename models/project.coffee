mongoose = require 'mongoose'

ProjectSchema = module.exports = new mongoose.Schema
  name:
    type: String
    required: true
  rate: Number  # $/hr

Project = mongoose.model 'Project', ProjectSchema
