socket = require("socket")

function serve()
	local lsock = assert(socket.bind("*", 7002))
	lsock:settimeout(0.01)
	local socks = {}

	local function accept()
		local sock = lsock:accept()
		if sock ~= nil then
			sock:settimeout(0.01)
			sock:send("!Hello!")
			table.insert(socks, sock)
		end
		coroutine.yield()
		return accept()
	end

	local function dispatch()
		for _, sock in ipairs(socket.select(socks, nil, 0.1)) do
			msg, er = sock:receive()
			if msg ~= nil then sendtoall(msg) end
		end
		coroutine.yield()
		return dispatch()
	end

	local function sendtoall(msg)
		for _, sock in ipairs(socks) do sock:send(msg) end
	end

	local coroutines = {
		coroutine.create(function () accept() end),
		coroutine.create(function () dispatch() end)
	}

	while true do 
		for _, co in ipairs(coroutines) do coroutine.resume(co) end 	
	end

	lsock:close()
end

serve()

