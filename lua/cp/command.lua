return {
	receive = {
		run = function()
			require("cp.receive")
		end,
		complete = function()
		end
	},
	run = {
		run = function(test)
			local t = test[1]
			if t == "all" then
				print "ran all of em"
			end
		end,
		complete = function()
			return { "all" }
		end
	}
}
