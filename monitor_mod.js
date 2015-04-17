var usage = require('usage');

function trackPID(pid, interval, callback) {
  setTimeout(function checkUsage() {
    // you can use any valid PID instead
    usage.lookup(pid, { keepHistory: true }, function (err, result) {
      if (!err)
        callback(result);
      else
        console.error(err);
    });
    setTimeout(checkUsage, interval);
  }, interval);
};

module.exports = trackPID;
