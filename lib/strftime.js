var strftime = require('strftime').strftime;
Date.prototype.toLocaleFormat = function toLocaleFormat(fmt) {
  return strftime(fmt, this);
};
