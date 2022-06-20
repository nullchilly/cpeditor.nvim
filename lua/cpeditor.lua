local M = {}

local default_config = {
	integration = {
		bufferline = true,
		nvim_dap = true,
	},
	links = {
		["local"] = "~/code/local",
		["https://codeforces.com/contest/(%d+)/problem/(%w+)"] = "~/code/contest/codeforces",
		["https://codeforces.com/problemset/problem/(%d+)/(%w+)"] = "~/code/contest/codeforces",
	},
	layouts = {
		floating = {},
		default = {
			cmd = "set nosplitright | vs | setl wfw | wincmd w | bel sp | vs | vs | 1wincmd w",
			order = { 1, 2, 3, 4, 5 }, -- main, errors, input, output, expected output
		},
	},
	default_layout = "default",
	langs = {
		cpp = {
			main = { "sol.cpp", "g++ -Wall -O2 -o sol", "./sol" },
			brute = { "brute.cpp", "g++ -Wall -O2 -o brute", "./brute" },
			gen = { "gen.cpp", "g++ -Wall -O2 -o gen", "./gen" },
		},
	},
	default_lang = "cpp",
}

function M.highlight()
	-- Create cpeditor highlight groups
	local highlight_groups = {
		CpeditorHD = { fg = "#ffffff", bg = "#000000" },
		CpeditorfHD = { fg = "#000000", bg = "#ffffff" },
		CpeditorNA = { fg = "#ffffff", bg = "#ABB2BF" },
		CpeditorfNA = { fg = "#000000", bg = "#ABB2BF" },
		CpeditorPD = { fg = "#C678DD", bg = "#ffffff" },
		CpeditorfPD = { fg = "#000000", bg = "#ABB2BF" },
		CpeditorAC = { fg = "#ffffff", bg = "#98C379" },
		CpeditorfAC = { fg = "#000000", bg = "#98C379" },
		CpeditorWA = { fg = "#ffffff", bg = "#E06C75" },
		CpeditorfWA = { fg = "#000000", bg = "#E06C75" },
		CpeditorRE = { fg = "#ffffff", bg = "#61AFEF" },
		CpeditorfRE = { fg = "#000000", bg = "#61AFEF" },
		CpeditorTL = { fg = "#ffffff", bg = "#E5C07B" },
		CpeditorfTL = { fg = "#000000", bg = "#E5C07B" },
		CpeditorFL = { fg = "#000000", bg = "NONE" },
	}
	for k, v in pairs(highlight_groups) do
		vim.api.nvim_set_hl(0, k, v)
	end
end

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", user_config, default_config)

	local load_command = function(cmd, ...)
		local args = { ... }
		require("cpeditor.command")[cmd].run(args)
	end
	vim.api.nvim_create_user_command("Cpeditor", function(info)
		load_command(unpack(info.fargs))
	end, {
		nargs = "*",
		complete = function(_, line)
			local commands = require "cpeditor.command"
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

	-- create highlight groups
	M.highlight()

	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = function()
			require("cpeditor").highlight()
		end,
	})

	-- Change problem autocmd
	vim.api.nvim_create_autocmd("TabEnter", {
		pattern = "*",
		callback = function()
			require("cpeditor.problems").switch(vim.api.nvim_get_current_tabpage())
		end,
	})
end

return M
