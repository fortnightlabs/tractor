_ = require 'underscore'
async = require 'async'
mongoose = require 'mongoose'

Projects = {}
Project = mongoose.model 'Project'
Project.find (err, projects) ->
  projects.forEach (p) -> Projects[p.name] = p.id

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
  importId: mongoose.Schema.ObjectId

# indexes

ItemSchema.index { start: 1, end: 1 }, { unique: true }

# scopes

ItemSchema.namedScope 'search', (query) ->
  if match = query?.match /project:(\w+)/
    @where 'projectId', Projects[match[1]]
  else
    @where 'search', new RegExp query, 'i' if query?

ItemSchema.namedScope 'onDay', (date) ->
  day =
    if parts = date?.split '-'
      new Date parts[0], parts[1]-1, parts[2]
    else
      today = new Date
      new Date today.getFullYear(), today.getMonth(), today.getDate()
  nextDay = day.valueOf() + 86400000
  @where('start').gte(day).lt(nextDay)

ItemSchema.namedScope 'sorted', -> @asc 'start'

# statics

ItemSchema.static 'import', (items, callback) ->
  Rule = mongoose.model 'Rule'

  i = 0
  importId = new mongoose.Types.ObjectId
  insert = (item, fn) ->
    item.importId = importId
    Item.create item, (err, item) ->
      if err? then console.error 'create error:', err else i++
      fn()

  async.forEach items, insert, ->
    # apply rules to all imported items
    Rule.run { importId: importId }, (err, rules) ->
      return callback err if err?
      callback null, i

# callbacks

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
    search.push @info.to
    search.push @info.recipients
    search.push @info.subject
    search.push @info.url
    search.push @info.path
  @search = _.compact(search).join '\n'
  next()

Item = mongoose.model 'Item', ItemSchema
