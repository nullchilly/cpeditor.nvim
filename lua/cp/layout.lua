local config = CpConfig

-- For neovim >= 0.8
-- @param: num, clicks, button, flags
function ___cp_private.tab(num)
	CpProblem:tab(num)
end

function ___cp_private.test(num, _, button)
	if button == "r" then
		CpProblem:hide_show(num)
	else
		CpProblem:switch(num)
	end
	CpProblem:test(num)
end

-- For neovim <= 0.7.1
vim.cmd [[
	function ___cp_private_tab(num, clicks, button, flags)
		execute "lua require'cp.layout'.tab(" . a:num . ")"
	endfunction
	function ___cp_private_test(num, clicks, button, flags)
		if a:button == 'r'
			execute "lua CpProblem:hide_show(" . a:num . ")"
		else
			execute "lua CpProblem:test(" . a:num . ")"
		endif
	endfunction
]]

function CpProblemClass:tabline()
	local res = ""
	if config.bufferline_integration == false then
		for i, v in ipairs(CpProblemList) do
			if vim.api.nvim_get_current_tabpage() == v.tab_id then
				res = res .. "%#CpfNA#"
			else
				res = res .. "%#CpNA#"
			end
			res = res .. "%" .. i .. "@___cp_private_tab@ " .. v.name .. " "
		end
		res = res .. "%#CpFL#%T%="
	end
	if self.result == nil then
		return
	end
	for i, v in pairs(self.result) do
		print(i, v)
		res = res .. "%#Cp"
		if i == self.curTest then
			res = res .. "f"
		end
		res = res .. v .. "#"
		res = res .. "%" .. i .. "@___cp_private_test@"
		res = res .. " " .. i .. " "
	end

	return res
end

function CpProblemClass:problem(index)
	CpProblem = CpProblemList[index]
	self = CpProblem
	vim.cmd("tcd " .. self.path)
end

function CpProblemClass:wincmd(type, cmd)
	local convert = {
		main = self.win_id[1],
		err = self.win_id[2],
		inp = self.win_id[3],
		out = self.win_id[4],
		ans = self.win_id[5],
	}
	local index = convert[type]
	if index == 0 then
		return
	end
	vim.api.nvim_win_call(index, function()
		vim.cmd(cmd)
	end)
end

function CpProblemClass:layout()
	self:wincmd("main", "e!" .. self.lang.main[1])
	self:wincmd("err", "e! .err | set ft=cpp")
	self:test(self.curTest)
end

function CpProblemClass:sol(L)
	self.lang = config.langs[L]
	self:wincmd("main", "e! " .. self.lang.main[1])
	self:wincmd("err", "e! .err | set ft=" .. L)
end

function CpProblemClass:open()
	vim.cmd(config.layouts[config.default_layout].cmd)
	self.win_id = vim.api.nvim_tabpage_list_wins(0)
	self:sol(config.default_lang)
	self:layout()
end
