socket = require("socket")

function serve()
	local lsock = assert(socket.bind("*", 7002))
	lsock:settimeout(0)
	local socks = {}

	function accept()
		local sock = lsock:accept()
		if sock ~= nil then
			cli:settimeout(0)
			table.insert(socks, sock)
		end
		coroutine.yield()
		accept()
	end

	function dispatch()
		for _, sock in ipairs(socket.select(socks, nil, 50) do
			msg, er = cli:receive()
			if msg ~= nil then sendtoall(msg) end
		end
		coroutine.yield()
		dispatch()
	end

	function sendtoall(msg)
		for _, cli in ipairs(clis) do cli:send(msg) end
	end

	local coros = {}
	table.insert(coros, coroutine.create(function () accept() end))
	table.insert(coros, coroutine.create(function () dispatch() end))

	while 1 do
		for _, co in coros do coroutine.resume(co) end
	end

	lsock:close()
end


