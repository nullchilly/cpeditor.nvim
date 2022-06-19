local config = _G.cp_config

function Problem:tabline()
	local res = ""
	if config.bufferline_integration == false then
		for i, v in ipairs(_G.cp_problems) do
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

function Problem:problem(index)
	_G.cp_problem =_G.cp_problems[index]
	self = _G.cp_problem
	print(self.path)
	vim.cmd("tcd " .. self.path)
end

function Problem:wincmd(type, cmd)
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

function Problem:layout()
	self:wincmd("main", "e!" .. self.lang.main[1])
	self:wincmd("err", "e! .err | set ft=cpp")
	self:test(self.curTest)
end

function Problem:sol(L)
	self.lang = config.langs[L]
	vim.pretty_print(self.lang.main)
	self:wincmd("main", "e! " .. self.lang.main[1])
	self:wincmd("err", "e! .err | set ft=" .. L)
end

function Problem:open()
	vim.cmd(config.layouts[config.default_layout].cmd)
	self.win_id = vim.api.nvim_tabpage_list_wins(0)
	self:sol(config.default_lang)
	self:layout()
end
