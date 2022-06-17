local M = {}

local default_config = {
	links = {
		["https://codeforces.com/contest/(%d+)/problem/(%w+)"] = "/home/nullchilly/code/contest/codeforces",
		["https://codeforces.com/problemset/problem/(%d+)/(%w+)"] = "~/code/contest/codeforces",
		-- ["https://atcoder.jp/contests/(%d+)/tasks/(%w+%p%d)"]
	},
	layouts = {
		floating = {},
		default = {
			cmd = "set nosplitright | vs | setl wfw | wincmd w | bel sp | vs | vs | 1wincmd w",
			order = {1, 2, 3, 4, 5}, -- source, errors, input, output, expected output
		},
	},
	default_layout = "default"
}

function M.setup(user_config)
	_G.cp_config = vim.tbl_deep_extend("force", user_config, default_config)

	local load_command = function(cmd, ...)
		local args = { ... }
		require("cp.command")[cmd].run(args)
	end
	vim.api.nvim_create_user_command("Cp", function(info)
		load_command(unpack(info.fargs))
	end, {
		nargs = "*",
		complete = function(_, line)
			local commands = require "cp.command"
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
		end
	})
end

return M
