local config = CpConfig

-- neovim 0.8 only
function CpTab(num, clicks, button, flags)
	CpProblem:tab(num)
end

function CpTest(num, clicks, button, flags)
	if button == "r" then
		CpProblem:hide_show(num)
	else
		CpProblem:switch(num)
	end
	CpProblem:test(num)
end

function CpProblemClass:tabline()
	local res = ""
	if config.bufferline_integration == false then
		for i, v in ipairs(CpProblemList) do
			if vim.api.nvim_get_current_tabpage() == v.tab_id then
				res = res .. "%#CpfNA#"
			else
				res = res .. "%#CpNA#"
			end
			res = res .. "%" .. i .. "@CpTab@ " .. v.name .. " "
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
		res = res .. "%" .. i .. "@CpTest@"
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
