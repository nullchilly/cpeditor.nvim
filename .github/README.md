
# WARNING: Work in progress, breaking changes everywhere

# cp.nvim

A plugin written in lua for Competitive Programming

# Preview
![image](https://user-images.githubusercontent.com/56817415/174459273-c9e0fdbc-e06f-4d31-9e18-ab8ecd02e752.png)

# Installation

```lua
use {
	'nullchilly/cp.nvim',
	requires = 'nvim-lua/plenary.nvim'
}
```

# Features (Will update later)

- Problem parser

https://github.com/jmerle/competitive-companion
- Hotkey submit

https://github.com/xalanq/cf-tool
- Debugging

Work in progress
- Stresstest

Work in progress

# Setup

```lua
require("cp").setup {
	integration = {
		bufferline = false,
		nvim_dap = false
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
```lua
require("bufferline").setup {
	options = {
		mode = "tabs",
		name_formatter = function(tab)
			local error, problem_name = pcall(function() return vim.api.nvim_tabpage_get_var(tab.tabnr, "cp_problem_name") end)
			if error == false then
				return tab.name
			end
			return problem_name
		end,
		custom_areas = {
			right = function()
				local result = {}
				table.insert(result, {text = CpProblem:tabline()})
				return result
			end
		},
	},
}
```

- nvim-dap

# Example keymaps
```lua
vim.keymap.set("n", "<leader>x", "<cmd> tabclose <CR>") -- 	close tab
vim.keymap.set('n', 't', function()
	vim.cmd("Cp test " .. vim.v.count)
end)
```

# Acknowledgement
- https://github.com/p00f/cphelper.nvim My initial motivation to write this plugin
- https://github.com/xeluxee/competitest.nvim For great ideas
- https://github.com/cpeditor/cpeditor/ For not merging vim support
