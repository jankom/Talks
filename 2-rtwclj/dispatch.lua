socket = require("socket")

function serve(port)
	local lsock = assert(socket.bind("*", port))
	local coros = {}
	lsock:settimeout(0.01)

	function run()
		local sock = lsock:accept()
		if sock ~= nil then
			sock:settimeout(0.01)
			coros[sock] = coroutine.create(function () dispatch(sock) end)
		end
		for sock, co in pairs(coros) do 
			if coroutine.status(co) == 'dead' then coros[sock] = nil
			else coroutine.resume(co) end 
		end 	
		return run()
	end

	function dispatch(sock)
		sock:send("!Hello!")	
		repeat 
			local msg, er = sock:receive()
			coroutine.yield()
			if msg ~= nil then 
				sendtoall(msg)
			end
		until er == 'closed'
	end

	function sendtoall(msg)
		for sock, _ in pairs(coros) do sock:send(msg) end
	end

	run()
	lsock:close()
end

serve(7002)

