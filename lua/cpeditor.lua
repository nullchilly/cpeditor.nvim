local M = {}

local default_config = {
	integration = {
		bufferline = false, -- Set to true is recommended
		nvim_dap = false, -- Get test input file path
	},

	links = {
		["local"] = {
			path = "~/code/local",
			name = "${name}",
		},
		["https://codeforces.com/contest/(%d+)/problem/(%w+)"] = { -- https://codeforces.com/problemset/problem/464/E
			path = "~/code/contest/codeforces/${m1}/${m2}", -- m1 = 464, m2 = E
			name = "${m1}${m2}", -- name = 464E
		},
		["https://codeforces.com/problemset/problem/(%d+)/(%w+)"] = {
			path = "~/code/contest/codeforces/${m1}/${m2}",
			name = "${m1}${m2}",
		},
	},

	layouts = {
		only = {
			func = function() end,
			order = { 1, 0, 0, 0, 0 },
		},
		split = {
			func = function()
				vim.cmd "set nosplitright | vs | setl wfw | wincmd w | bel sp | vs | vs | 1wincmd w"
			end,
			order = { 1, 2, 3, 4, 5 }, -- main, errors, input, output, expected output
		},
		tree = {
			func = function()
				vim.cmd "execute 'NvimTreeToggle' | set nosplitright | 2wincmd w | vs | setl wfw | wincmd w | bel sp | sp | sp | 2wincmd w"
			end,
			order = { 2, 3, 4, 5, 6 },
		},
	},
	layout = "split",

	tests_format = {
		input = "tests/${tcnum}/${tcnum}.in",
		output = "tests/${tcnum}/${tcnum}.out",
		answer = "tests/${tcnum}/${tcnum}.ans",
		stderr = "tests/${tcnum}/${tcnum}.err",
	},

	langs = {
		cpp = {
			flags = {
				normal = "-std=c++20 -O2 -DTIMING -DLOCAL -ftree-vectorize -fopt-info-vec",
				debug = "-std=c++20 -g -Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wlogical-op -Wshift-overflow=2 -Wduplicated-cond -Wcast-qual -Wcast-align -Wno-variadic-macros -DDEBUG -DLOCAL -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector -fsanitize-address-use-after-scope", -- :Cpeditor flag debug
			},
			flag = "normal",
			sources = {
				["main.cpp"] = {
					compile = "g++ ${flag} main.cpp -o main",
					run = "./main < tests/${tcnum}/${tcnum}.in > tests/${tcnum}/${tcnum}.out 2> tests/${tcnum}/${tcnum}.err",
				},
				-- Stress testing
				["brute.cpp"] = {
					compile = "g++ ${flag} brute.cpp -o brute",
					run = "./brute < ${input} > ${output} 2> ${stderr}",
				},
				["gen.cpp"] = {
					compile = "g++ ${flag} -o gen",
					run = "./gen < ${input} > ${output} 2> ${stderr}",
				},
				["stress.cpp"] = {
					compile = "g++ ${flag} -o stress",
					run = "./stress",
				},
			},
			source = "main.cpp",
		},
		python = {
			sources = {
				["${pname}.py"] = { -- 464E.py
					compile = [[python -c "import py_compile; py_compile.compile('${pname}.py')"]],
					run = "pypy ${pname.py}",
				},
			},
			source = "${pname}.py",
		},
	},
	lang = "cpp",
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
		CpeditorWAcount = { fg = "#E06C75", bg = "NONE" },
		CpeditorACcount = { fg = "#98C379", bg = "NONE" },
	}
	for k, v in pairs(highlight_groups) do
		vim.api.nvim_set_hl(0, k, v)
	end
end

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("keep", user_config, default_config)

	-- create commands
	require("cpeditor.command").load()

	-- Set tabline now
	if M.config.integration.bufferline == false then
		vim.o.tabline = "%!v:lua.require('cpeditor.layout').tabline()"
	end

	-- create highlight groups
	M.highlight()

	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = function()
			require("cpeditor").highlight()
		end,
	})

	-- change problem on TabEnter
	vim.api.nvim_create_autocmd("TabEnter", {
		pattern = "*",
		callback = function()
			require("cpeditor.problems").switch(vim.api.nvim_get_current_tabpage())
		end,
	})

	vim.api.nvim_create_autocmd("TabClosed", {
		pattern = "*",
		callback = function()
			local tab_id = tonumber(vim.fn.expand "<afile>")
			require("cpeditor.problems").delete(tab_id)
		end,
	})

	vim.api.nvim_create_autocmd("VimLeave", {
		pattern = "*",
		callback = function()
			require("cpeditor.receive").stop()
		end,
	})
end

return M
