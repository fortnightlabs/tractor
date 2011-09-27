var util = require('util')
  , http = require('http')
  , res = http.ServerResponse.prototype
  , render = res.render;

res.render = function() {
  util.log(('Rendering ' + arguments[0]).green);
  this.local('template', arguments[0]);
  render.apply(this, arguments);
};
