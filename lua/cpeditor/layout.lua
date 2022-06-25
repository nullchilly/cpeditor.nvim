local M = {}

local config = require("cpeditor").config
local problems = require "cpeditor.problems"

-- @v:lua@ in the tabline only supports global functions, so this is
-- the only way to add click handlers without autoloaded vimscript functions
_G.___cpeditor_private = _G.___cpeditor_private or {} -- to guard against reloads

-- For neovim >= 0.8
-- @param: num, clicks, button, flags
function ___cpeditor_private.tab(num)
	require("cpeditor.test").tab(num)
end

function ___cpeditor_private.test(num, _, button)
	if button == "r" then
		require("cpeditor.test").toggle(num)
	else
		require("cpeditor.test").switch(num)
	end
end

-- For neovim <= 0.7.1
vim.cmd [[
	function ___cpeditor_private_tab(num, clicks, button, flags)
		execute "lua require'cpeditor.problem'.switch(" . a:num . ")"
	endfunction
	function ___cpeditor_private_test(num, clicks, button, flags)
		if a:button == 'r'
			execute "lua require'cpeditor.test'.toggle(" . a:num . ")"
		else
			execute "lua require'cpeditor.test'.switch(" . a:num . ")"
		endif
	endfunction
]]

function M.tabline()
	local problem = problems.current
	if problem == nil then
		return ""
	end
	local component_problem = ""
	if config.integration.bufferline == false then
		for i, p in ipairs(problems.list) do
			if vim.api.nvim_get_current_tabpage() == p.tab_id then
				component_problem = component_problem .. "%#CpeditorfNA#"
			else
				component_problem = component_problem .. "%#CpeditorNA#"
			end
			component_problem = component_problem .. "%" .. i .. "@___cpeditor_private_" .. "tab@ " .. p.name .. " "
		end
		component_problem = component_problem .. "%#CpeditorFL#%T%="
	end
	if problem.result == nil then
		return
	end
	local component_test = ""
	local wa = 0
	local ac = 0
	local tot = 0
	for i, v in pairs(problem.result) do
		if v == "AC" then
			ac = ac + 1
		elseif v ~= "NA" and v ~= "HD" then
			wa = wa + 1
		end
		tot = tot + 1
		component_test = component_test .. "%#Cpeditor"
		if i == problem.curTest then
			component_test = component_test .. "f"
		end
		component_test = component_test .. v .. "#"
		component_test = component_test .. "%" .. i .. "@___cpeditor_private_" .. "test@"
		component_test = component_test .. " " .. i .. " "
	end

	local component_status = problem.status or "Coding"
	component_status = component_status .. " "

	local component_count = "%#CpeditorWAcount# "
		.. tostring(wa)
		.. " %#CpeditorfFL#/"
		.. "%#CpeditorACcount# "
		.. tostring(ac)
		.. " %#CpeditorfFL#/ "
		.. tostring(tot)
		.. " "

	return component_problem .. component_count .. component_status .. component_test
end

function M.wincmd(type, cmd)
	local problem = problems.current
	local convert = {
		main = problem.win_id[problem.layout.order[1]],
		err = problem.win_id[problem.layout.order[2]],
		inp = problem.win_id[problem.layout.order[3]],
		out = problem.win_id[problem.layout.order[4]],
		ans = problem.win_id[problem.layout.order[5]],
	}
	local index = convert[type]
	if index == nil then
		return
	end
	vim.api.nvim_win_call(index, function()
		vim.cmd(cmd)
	end)
end

function M.change(layout)
	if layout then
		vim.cmd "only"
	else
		layout = config.layout
	end
	local problem = problems.current
	problem.layout = config.layouts[layout]
	problem.layout.func()
	problem.win_id = vim.api.nvim_tabpage_list_wins(0)
	require("cpeditor.test").switch(problem.curTest)
	require("cpeditor.lang").set(config.lang)
end

return M
