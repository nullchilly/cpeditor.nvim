return {
	receive = {
		run = function()
			require "cp.receive"
		end,
		complete = function() end,
	},
	test = {
		run = function(t)
			_G.cp_problem:test(tonumber(t[1]))
		end,
		complete = function()
			-- return require("cp.problem".get_tests)
		end,
	},
	compile = {
		run = function(test)
			local t = test[1]
		end
	},
	run = {
		run = function(test)
			local t = test[1]
			if t == "all" then
				_G.cp_problem:compile()
			end
			if t ~= "all" then
				t = tonumber(t)
			end
			_G.cp_problem:run(t)
		end,
		complete = function()
			return { "all" }
		end,
	},
}
