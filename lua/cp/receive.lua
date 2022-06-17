local uv = vim.loop
local path = require("plenary.path")

local function process(data)
	local json = vim.fn.json_decode(data)
	vim.pretty_print(json.url)
	for link, dir in pairs(_G.cp_config.links) do
		for k, v in (json.url):gmatch(link) do
			print(k, v)
			local contest_dir = path:new(dir)
			contest_dir:expand()
			local problem_path = contest_dir:joinpath(k, v)
			problem_path:joinpath("tests")
			problem_path:mkdir({ exists_ok = true, parents = true })
			for i, test in pairs(json.tests) do
				i = tostring(i)
				problem_path:joinpath(i):mkdir({ exists_ok = true, parents = true })
        problem_path:joinpath(i, i .. ".in"):write(test.input, "w")
        problem_path:joinpath(i, i .. ".ans"):write(test.output, "w")
				vim.api.nvim_set_current_dir(problem_path.filename)
			end
		end
	end
end

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
				process(buffer)
			end)
			Server:shutdown()
		end
	end)
end)
uv.run()
