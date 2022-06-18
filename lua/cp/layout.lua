local M = {}
local problems = _G.cp_problems
local config = _G.cp_config

function M:tabline()
  local res = ""
  -- for i, v in ipairs(problems) do
  --   if _G.cp_cur_problem == i then res = res .. "%#CpfNA#"
  --   else res = res .. "%#CpNA#" end
  --   res = res .. "%" .. i .. "@CpTab@ " .. v.name .. " "
  -- end
  -- res = res .. "%#CpFL#%T%="
	local s = problems[_G.cp_cur_problem]
	for i, v in pairs(s.tests_result) do
    res = res .. "%#Cp"
    if i == self.curTest then res = res .. "f" end
    res = res .. v .. "#"
    res = res .. "%" .. i .. "@CpTest@"
    res = res .. " " .. i .. " "
  end

  vim.o.tabline = _G.nvim_bufferline() .. res
end

function M.tab(index)
	_G.cp_cur_problem = index
	vim.api.nvim_set_current_tabpage(index)
	vim.api.nvim_set_current_dir(problems[index].path)
	M.tabline()
end

function M:open()
	-- problems[_G.cp_cur_problem] = 
	vim.cmd(config.layouts[config.default_layout].cmd)
	vim.pretty_print(vim.api.nvim_tabpage_list_wins(_G.cp_cur_problem))
end

return M
