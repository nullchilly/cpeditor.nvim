local M = {}

local problem = require "cpeditor.problems"
local test = require "cpeditor.test"

local function empty() end

local function getTestList()
	local tests = vim.tbl_keys(problem.current.result)
	for i, v in ipairs(tests) do
		tests[i] = tostring(v)
	end
	table.insert(tests, "all")
	return tests
end

local commands = {
	receive = {
		run = function(args)
			require("cpeditor.receive").start(args)
		end,
		complete = empty,
	},
	stop = {
		run = function()
			require("cpeditor.receive").stop()
		end,
		complete = empty,
	},
	layout = {
		run = function(layout)
			require("cpeditor.layout").change(layout[1])
		end,
		complete = empty,
	},
	test = {
		run = function(t)
			t = t[1]
			t = tonumber(t)
			test.switch(t)
		end,
		complete = getTestList,
	},
	compile = {
		run = function()
			test.compile()
		end,
		complete = empty,
	},
	compile_run = {
		run = function()
			test.compile "all"
		end,
		complete = empty,
	},
	run = {
		run = function(t)
			t = t[1]
			if t == "all" then
				test.run_all()
				return
			end
			t = tonumber(t)
			test.run(t)
		end,
		complete = getTestList,
	},
}

local load_command = function(cmd, ...)
	local args = { ... }
	commands[cmd].run(args)
end

function M.load()
	vim.api.nvim_create_user_command("Cpeditor", function(info)
		load_command(unpack(info.fargs))
	end, {
		nargs = "*",
		complete = function(_, line)
			local builtin_list = vim.tbl_keys(commands)

			local l = vim.split(line, "%s+")
			local n = #l - 2

			if n == 0 then
				return vim.tbl_filter(function(val)
					return vim.startswith(val, l[2])
				end, builtin_list)
			end

			if n == 1 then
				local extension = commands[l[2]]
				if extension then
					return vim.tbl_filter(function(val)
						return vim.startswith(val, l[3])
					end, extension.complete())
				end
			end
		end,
	})
end

return M
