local uv = vim.loop
local problem = require "cpeditor.problems"

local buffer = ""
Server = uv.new_tcp()
Server:bind("127.0.0.1", 27121)
Server:listen(128, function(err)
	assert(not err, err)
	local client = uv.new_tcp()
	Server:accept(client)
	client:read_start(function(error, chunk)
		assert(not error, error)
		if chunk then
			buffer = buffer .. chunk
		else
			client:shutdown()
			client:close()
			local lines = {}
			for line in string.gmatch(buffer, "[^\r\n]+") do
				table.insert(lines, line)
			end
			buffer = lines[#lines]
			vim.schedule(function()
				problem.new(vim.fn.json_decode(buffer))
			end)
			Server:shutdown()
		end
	end)
end)
uv.run()
