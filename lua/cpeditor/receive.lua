local M = {}

local uv = vim.loop
local problem = require "cpeditor.problems"

function M.start(forever)
	local buffer = ""
	M.server = uv.new_tcp()
	M.server:bind("127.0.0.1", 1327)
	M.server:listen(128, function(err)
		assert(not err, err)
		local client = uv.new_tcp()
		M.server:accept(client)
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
				M.server:shutdown()
				if forever == nil then
					M.server:close()
				end
			end
		end)
	end)
	uv.run()
end

function M.stop()
	M.server:shutdown()
end

return M
