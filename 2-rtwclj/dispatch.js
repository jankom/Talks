var tcp = require("tcp");
var CLIENTS = [];

var server = tcp.createServer(
	function (socket) {
	
		CLIENTS.push(socket);
		socket.setTimeout(0);

		socket.addListener("connect", function () {
			socket.send("!Welcome!\n");
		});

		socket.addListener("receive", function (data) {
			arr_each(CLIENTS, function(c) {
				c.send(data);
			});
		});

		socket.addListener("eof", function() {
			socket.close();
		});

		socket.addListener("close", function() {
			arr_remove(CLIENTS, socket);
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
