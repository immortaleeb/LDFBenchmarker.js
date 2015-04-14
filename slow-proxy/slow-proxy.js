var args = process.argv.slice(2);

var http = require('http'),
  httpProxy = require('http-proxy');

var proxy = httpProxy.createProxyServer({
    target: {
      host: 'localhost',
      port: args[0]
    }
  });

http.createServer(function (req, res) {
  setTimeout(function () {
    proxy.web(req, res);
  }, args[2]);
}).listen(args[1], function () {
  console.log('proxy listening on port %d', args[1]);
});
