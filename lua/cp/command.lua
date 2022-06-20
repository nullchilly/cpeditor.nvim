local problem = require "cp.problems"
local test = require "cp.test"

return {
	receive = {
		run = function()
			require "cp.receive"
		end,
		complete = function() end,
	},
	test = {
		run = function(t)
			t = t[1]
			-- if t == "all" then
			-- end
			t = tonumber(t)
			test.switch(t)
		end,
		complete = function()
			return table.insert(vim.tbl_keys(problem.current_problem.result), "all")
		end,
	},
	compile = {
		run = function()
			test.compile()
		end,
		complete = function() end,
	},
	compile_run = {
		run = function()
			test.compile "all"
		end,
		complete = function() end,
	},
	run = {
		run = function(t)
			t = t[1]
			if t == "all" then
				test.compile()
			end
			if t ~= "all" then
				t = tonumber(t)
			end
			test.run(t)
		end,
		complete = function()
			return { "all" }
		end,
	},
}
