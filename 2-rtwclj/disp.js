var tcp = require("tcp");
Array.prototype.remove = function(e) {
for (var i = 0; i < this.length; i++)
if (e == this[i]) return this.splice(i, 1);
}

Array.prototype.each = function(fn) {
for (var i = 0; i < this.length; i++) fn(this[i]);
}

function Client(connection) {
this.name = null;
this.connection = connection;
}

var clients = [];

var server = tcp.createServer(function (socket) {
var client = new Client(socket);
clients.push(client);

socket.setTimeout(0);
socket.setEncoding("utf8");

socket.addListener("connect", function () {
socket.send("Welcome, enter your username:\n");
});

socket.addListener("receive", function (data) {
if (client.name == null) {
client.name = data.match(/\S+/);
socket.send("===========\n");
clients.each(function(c) {
if (c != client)
c.connection.send(client.name + " has joined.\n");
});
return;
}

var command = data.match(/^\/(.*)/);
if (command) {
if (command[1] == 'users') {
clients.each(function(c) {
socket.send("- " + c.name + "\n");
});
}
else if (command[1] == 'quit') {
socket.close();
}
return;
}

clients.each(function(c) {
if (c != client)
c.connection.send(client.name + ": " + data);
});
});

socket.addListener("eof", function() {
socket.close();
});

socket.addListener("close", function() {
clients.remove(client);

clients.each(function(c) {
c.connection.send(client.name + " has left.\n");
});
});
});

server.listen(7000);

