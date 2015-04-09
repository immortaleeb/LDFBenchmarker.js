var fs = require('fs'),
  ldf = require('ldf-client'),
  //ldfBloom = require(''),
  LineByLineReader = require('line-by-line');

var args = process.argv.slice(2);
if (args.length < 1 || args.length > 3 || /^--?h(elp)?$/.test(args[0])) {
  console.log('usage: ./run-tests.js queryFile startFragment');
  return process.exit(1);
}

var file = args[0],
    startFragment = args[1],
    timeOut = args[2] || 60000; // default 60s

var fragmentsClient = new ldf.FragmentsClient(startFragment);
ldf.Logger.setLevel('warning');

var lr = new LineByLineReader(file);

var id = 0;


console.log("file,id,query,timeFirst,time,resultCount");

lr.on('error', function (err) {
  // 'err' contains error object
  console.error(err);
});

lr.on('line', function (query) {
  // 'line' contains the current line without the trailing newline character.
  lr.pause();

  id++;

  var start = process.hrtime(),
    timeFirst = null,
    time = null,
    resultCount = 0,
    timeOut = false;

  var results = new ldf.SparqlIterator(query, {
    fragmentsClient: fragmentsClient
  });

  setTimeout(function () {
    timeOut = true;
    results._end();
  }, 5000)

  results.on('data', function (result) {
    if (timeFirst === null)
      timeFirst = process.hrtime(start);

    resultCount++;
  });
  results.on('end', function (end) {
    var time = process.hrtime(start);

    console.log("%s,%d,%s,%d,%d,%d,%s", file, id, query, timeFirst ? timeFirst[0] * 1000 + (timeFirst[1] / 1000000) : -1, time[0] * 1000 + (time[1] / 1000000), resultCount, timeOut);

    lr.resume();
  });
});

lr.on('end', function () {
  // All lines are read, file is closed now.
  console.error('--- End of run ---');
});
