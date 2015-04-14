#!/usr/bin/env node

/* Simple benchmarking application for testing different TPF clients */

var fs = require('fs'),
  LineByLineReader = require('line-by-line');

var args = process.argv.slice(2);
if (args.length < 2 || args.length > 4 || /^--?h(elp)?$/.test(args[0])) {
  console.log('usage: ./run-tests.js queryFile startFragment [timeout [client=ldf-client]]');
  return process.exit(1);
}

var file = args[0],
    startFragment = args[1],
    timeOut = args[2] || 60000, // default 60s
    ldf = require(args[3] || 'ldf-client');

ldf.Logger.setLevel('warning');

var fragmentsClient = new ldf.FragmentsClient(startFragment);

var requestCount = 0;
fragmentsClient._httpClient._logger.info = function () {
  requestCount++;
}

var lr = new LineByLineReader(file);

var id = 0;


console.log("file,id,query,timeFirst,time,resultCount,requestCount,timeOut");

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

    console.log("%s,%d,%s,%d,%d,%d,%d,%s", file, id, query, timeFirst ? timeFirst[0] * 1000 + (timeFirst[1] / 1000000) : -1, time[0] * 1000 + (time[1] / 1000000), resultCount, requestCount, timeOut);

    lr.resume();
  });
});

lr.on('end', function () {
  // All lines are read, file is closed now.
  console.error('--- End of run ---');
});
