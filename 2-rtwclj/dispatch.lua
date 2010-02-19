socket = require("socket")

function serve()
	local lsock = assert(socket.bind("*", 7002))
	local coros = {}
	local socks = {}
	lsock:settimeout(0.01)

	local function accept()
		local sock = lsock:accept()
		if sock ~= nil then
			sock:settimeout(0.41)
			table.insert(coros, coroutine.create(function () dispatch(sock) end))
		end
		for _, co in ipairs(coros) do coroutine.resume(co) end 	
		return accept()
	end

	function dispatch(sock)
		table.insert(socks, sock)
		local i = # socks
		sock:send("!Hello!")	
		local er = nil
		while er ~= 'closed' do
			msg, er = sock:receive()
			coroutine.yield()
			if msg ~= nil then 
				print "sending" 
				sendtoall(msg)
				-- coroutine.yield()
			end
		end
		table.remove(socks, i)
	end

	function sendtoall(msg)
		for _, sock in ipairs(socks) do sock:send(msg) end
	end

	accept()
	lsock:close()
end

serve()

