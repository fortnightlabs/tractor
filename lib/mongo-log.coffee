require 'colors'
inspect = require('util').inspect

module.exports = (mongo) ->
  executeCommand = mongo.Db.prototype.executeCommand

  commandName = (command) ->
    switch command.constructor
      when mongo.BaseCommand        then 'base'
      when mongo.DbCommand          then 'db'
      when mongo.DeleteCommand      then 'delete'
      when mongo.GetMoreCommand     then 'get_more'
      when mongo.InsertCommand      then 'insert'
      when mongo.KillCursorCommand  then 'kill_cursor'
      when mongo.QueryCommand       then 'query'
      when mongo.UpdateCommand      then 'update'

  mongo.Db.prototype.executeCommand = (db_command, options, callback) ->
    output = collectionName: db_command.collectionName
    for k in [ 'query', 'documents', 'spec', 'document', 'selector', \
               'returnFieldSelector', 'numberToSkip', 'numberToReturn' ]
      output[k] = db_command[k] if db_command[k]
    console.log "#{commandName(db_command).underline}: #{inspect(output, null, 8)}".grey

    executeCommand.apply this, arguments

    ###
    ms = Date.now()
    executeCommand.call this, db_command, options, ->
      took = Date.now() - ms
      console.log inspect(output, null, 8) + ' ' + took + ' ms'
      callback = options if !callback && typeof(options) == 'function'
      callback.apply this, arguments if callback
    ###
