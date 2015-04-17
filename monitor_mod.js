var usage = require('usage');

function trackPID(pid, interval, callback) {
  this._stop = false;
  var self = this;
  setTimeout(function checkUsage() {
    // you can use any valid PID instead
    usage.lookup(pid, { keepHistory: true }, function (err, result) {
      if (!err)
        callback(result);
      else
        console.error(err);
    });
    if (self._stop)
      setTimeout(checkUsage, interval);
  }, interval);
};

trackPID.prototype.stop = function () {
  this._stop = true;
}

module.exports = trackPID;
