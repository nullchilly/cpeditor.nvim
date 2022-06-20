local M = {}

local config = require("cp").config
local problems = require("cp.problems")

-- @v:lua@ in the tabline only supports global functions, so this is
-- the only way to add click handlers without autoloaded vimscript functions
_G.___cp_private = _G.___cp_private or {} -- to guard against reloads

-- For neovim >= 0.8
-- @param: num, clicks, button, flags
function ___cp_private.tab(num)
	require("cp.test").tab(num)
end

function ___cp_private.test(num, _, button)
	if button == "r" then
		require("cp.test").toggle(num)
	else
		require("cp.test").switch(num)
	end
end

-- For neovim <= 0.7.1
vim.cmd [[
	function ___cp_private_tab(num, clicks, button, flags)
		execute "lua require'cp.layout'.tab(" . a:num . ")"
	endfunction
	function ___cp_private_test(num, clicks, button, flags)
		if a:button == 'r'
			execute "lua require'cp.layout'.toggle(" . a:num . ")"
		else
			execute "lua require'cp.layout'.test(" . a:num . ")"
		endif
	endfunction
]]

function M.tabline(problem, problemList)
	local res = ""
	if config.bufferline_integration == false then
		for i, v in ipairs(problemList) do
			if vim.api.nvim_get_current_tabpage() == v.tab_id then
				res = res .. "%#CpfNA#"
			else
				res = res .. "%#CpNA#"
			end
			res = res .. "%" .. i .. "@___cp_private_" .. "tab@ " .. v.name .. " "
		end
		res = res .. "%#CpFL#%T%="
	end
	if problem.result == nil then
		return
	end
	for i, v in pairs(problem.result) do
		res = res .. "%#Cp"
		if i == problem.curTest then
			res = res .. "f"
		end
		res = res .. v .. "#"
		res = res .. "%" .. i .. "@___cp_private_" .. "test@"
		res = res .. " " .. i .. " "
	end

	return res
end

function M.wincmd(type, cmd)
	local problem = problems.current_problem
	local convert = {
		main = problem.win_id[1],
		err = problem.win_id[2],
		inp = problem.win_id[3],
		out = problem.win_id[4],
		ans = problem.win_id[5],
	}
	local index = convert[type]
	if index == 0 then
		return
	end
	vim.api.nvim_win_call(index, function()
		vim.cmd(cmd)
	end)
end

function M.layout()
	local problem = problems.current_problem
	-- M.wincmd("main", "e!" .. problem.lang.main[1])
	M.wincmd("err", "e! .err | set ft=cpp")
	vim.pretty_print(problem)
	require("cp.test").switch(problem.curTest)
end

function M.open()
	local problem = problems.current_problem
	print(config.layouts[config.default_layout].cmd)
	vim.cmd(config.layouts[config.default_layout].cmd)
	problem.win_id = vim.api.nvim_tabpage_list_wins(0)
	-- problem:sol(config.default_lang)
	M.layout()
end

return M
