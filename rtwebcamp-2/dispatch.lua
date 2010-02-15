function list_iter (t)
  local i = 0
  local n = table.getn(t)
  return function ()
		   i = i + 1
		   if i <= n then return t[i] end
		 end
end

function serve()
	local sock = require("socket")
	local srv = assert(sock.bind("*", 9049))
	local clients = {}
	print ("server created 9049")

	function acceptClients()
		srv:settimeout(0)
		local client = srv:accept()
		if client ~= nil then
			print("accepted con")
			cli:settimeout(0.01)
			table.insert(clients, client)
		end
		coroutine.yield()
	end

	function dispatchMessages()
		for client in list_iter(socket.select(clients, nil, 50) do
			msg, er = cli:receive()
			if msg ~= nil then
				if msg == "[STOP]" then cli:close()
				else sendToAll(msg) end
				print("sending>> " .. msg)
			end
			coroutine.yield()
		end
	end

	function sendToAll(msg)
		for cli in list_iter(clis) do 
			cli:send(msg)
			coroutine.yield() 
		end
	end

	function closeClients()
		for cli in list_iter(clis) do cli:close() end
	end

	while 1 do
		acceptClients()
		dispatchMessages()
	end

	closeClients()
	srv:close()
end

local coServe = coroutine.create(function () serve() end)

while coroutine.status(coServe) ~= "dead" do
	coroutine.resume(coServe)
end

