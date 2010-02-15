var tcp = require("tcp");

Array.prototype.remove = function(e) {
	for (var i = 0; i < this.length; i++)
		if (e == this[i]) return this.splice(i, 1);
}

Array.prototype.each = function(fn) {
	for (var i = 0; i < this.length; i++) fn(this[i]);
}

var clients = [];

var server = tcp.createServer(function (socket) {
	
	clients.push(socket);

	socket.setTimeout(0);

	socket.addListener("connect", function () {
		socket.send("s> Welcome!\n");
	});

	socket.addListener("receive", function (data) {
		clients.each(function(c) {
			c.send("e> " + data);
		});
	});

	socket.addListener("eof", function() {
		socket.close();
	});

	socket.addListener("close", function() {
		clients.remove(socket);
	});
});

server.listen(7000);
