

# cp.nvim

A plugin written in lua for Competitive Programming

# Preview

# Features

- Problem parser (https://github.com/jmerle/competitive-companion)
- Multiple problem
- Extensive multitest
- Hotkey submit (https://github.com/xalanq/cf-tool)
- Stresstest
- Terminal intergration

- GDB support (https://github.com/mfussenegger/nvim-dap)

Note: To see all the available functions use

# Installation

```lua
use 'nullchilly/cp.nvim'
```

# Setup

```lua
require("cp").setup {
	bufferline_integration = false,
	links = {
		["local"] = "~/code/local",
		["https://codeforces.com/contest/(%d+)/problem/(%w+)"] = "~/code/contest/codeforces",
		["https://codeforces.com/problemset/problem/(%d+)/(%w+)"] = "~/code/contest/codeforces",
	},
	layouts = {
		floating = {},
		default = {
			cmd = "set nosplitright | vs | setl wfw | wincmd w | bel sp | vs | vs | 1wincmd w",
			order = {1, 2, 3, 4, 5}, -- main, errors, input, output, expected output
		},
	},
	default_layout = "default",
	langs = {
    cpp = {
			main = {"sol.cpp", "g++ -Wall -O2 -o sol", "./sol"},
			brute = {"brute.cpp", "g++ -Wall -O2 -o brute", "./brute"},
			gen = {"gen.cpp", "g++ -Wall -O2 -o gen", "./gen"},
		}
  },
	default_lang = "cpp"
}
```

# Integrations

- Bufferline
set `bufferline_integration = true`, example config:
```lua
require("bufferline").setup {
	options = {
		mode = "tabs",
		close_command = "tabclose",
		right_mouse_command = "tabclose",
		left_mouse_command = "tabnew %d",
		offsets = {
			{
				filetype = "NvimTree",
				text = "",
				padding = 1,
			},
		},
		name_formatter = function(tab)  -- tab contains a "name", "path" and "tabnr"
			local error, problem_name = pcall(function() return vim.api.nvim_tabpage_get_var(tab.tabnr, "cp_problem_name") end)
			if error == false then
				return tab.name
			end
			return problem_name
		end,
		custom_areas = {
			right = function()
				local result = {}
				table.insert(result, {text = _G.cp_problem:tabline()})
				return result
			end
		},
	},
}
```

# Keymaps
```lua
vim.keymap.set("n", "<leader>x", "<cmd> tabclose <CR>") --"	close buffer"
vim.keymap.set('n', 't', function()
	vim.cmd("Cp test " .. vim.v.count)
end)
```
