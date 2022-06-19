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
		CpProblem:test(t)
		end,
		complete = function()
			return table.insert(vim.tbl_keys(CpProblem.result), "all")
		end,
	},
	compile = {
		run = function()
			CpProblem:compile()
		end,
		complete = function() end,
	},
	compile_run = {
		run = function()
			CpProblem:compile "all"
		end,
		complete = function() end,
	},
	run = {
		run = function(test)
			local t = test[1]
			if t == "all" then
				CpProblem:compile()
			end
			if t ~= "all" then
				t = tonumber(t)
			end
			CpProblem:run(t)
		end,
		complete = function()
			return { "all" }
		end,
	},
}
