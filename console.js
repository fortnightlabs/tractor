require('coffee-script');
require('colors');

var repl = require('repl')
  , context = repl.start().context;

context.app = require('./config/application');
context.Item = context.app.db.model('Item');

process.stdin.on('close', function() {
  process.exit();
});
