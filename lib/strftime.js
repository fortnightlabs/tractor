var strftime = require('strftime').strftime;
Date.prototype.toLocaleFormat = function toLocaleFormat(fmt) { strftime(fmt, this); };
