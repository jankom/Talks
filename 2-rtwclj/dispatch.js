var tcp = require("tcp");
var socks = [];

var server = tcp.createServer(
	function (sock) {
	
		socks.push(sock);
		sock.setTimeout(0);

		sock.addListener("connect", function () {
			sock.send("!Welcome!\n");
		});

		sock.addListener("receive", function (data) {
			arr_each(socks, function(c) {
				c.send(data);
			});
		});

		sock.addListener("eof", function() {
			sock.close();
		});

		sock.addListener("close", function() {
			arr_remove(socks, sock);
		});
	}
);

// helper functions
arr_remove = function(arr, e) {
	for (var i = 0; i < arr.length; i++)
		if (e == arr[i]) return arr.splice(i, 1);
}

arr_each = function(arr, fn) {
	for (var i = 0; i < arr.length; i++) fn(arr[i]);
}

// run it
server.listen(7000);
