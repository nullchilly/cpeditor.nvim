local M = {}
local path = require "plenary.path"
local config = _G.cp_config

local function parse_link(url)
	for link, dir in pairs(config.links) do
		for k, v in (url):gmatch(link) do
			return { k, v, dir }
		end
	end
end

function M:tabline()
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

function M:problem(index)
	self = _G.cp_problems[index]
	_G.cp_problem = self
end

function M:wincmd(type, cmd)
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

function M:layout()
	self:wincmd("main", "e!" .. self.lang.main[1])
	self:wincmd("err", "e! .err | set ft=cpp")
	self:test(self.curTest)
end

function M:sol(L)
	self.lang = config.langs[L]
	vim.pretty_print(self.lang.main)
	self:wincmd("main", "e! " .. self.lang.main[1])
	self:wincmd("err", "e! .err | set ft=" .. L)
end

function M:test(t)
	if not self.result[t] then
		return
	end
	self:wincmd("err", string.format("e! tests/%d/%d.err", t, t))
	self:wincmd("inp", string.format("e! tests/%d/%d.in", t, t))
	self:wincmd("out", string.format("e! tests/%d/%d.out", t, t))
	self:wincmd("ans", string.format("e! tests/%d/%d.ans", t, t))
	self.curTest = t
end

-- TODO: refactor old codes below
function M:insert(t)
	local s = P[N]
	s.result[t] = "NA"
	os.execute(string.format("mkdir -p %s/tests/%d", s.problemPath, t))
	test(t)
	info "w"
	inp "w"
	out "w"
	ans "w"
end

function M:erase(t)
	local s = P[N]
	if not t then
		t = s.curTest
	end
	os.execute(string.format("rm -r %s/tests/%d", s.problemPath, t))
	s.result[t] = nil
	tabline()
end

function M:hide_show(t)
	s = P[N]
	if not t then
		t = s.curTest
	end
	if s.result[t] == "HD" then
		s.result[t] = "NA"
	else
		s.result[t] = "HD"
	end
	tabline()
end

function M:show_all()
	for t, v in pairs(self.result) do
		if s.result[t] == "HD" then
			s.result[t] = "NA"
		end
	end
	tabline()
end

function M:invert()
	s = P[N]
	for t, v in pairs(self.result) do
		if s.result[t] == "HD" then
			s.result[t] = "NA"
		else
			s.result[t] = "HD"
		end
	end
	tabline()
end

function M:hide(stat)
	s = P[N]
	for t, v in pairs(s.result) do
		if v == stat then
			s.result[t] = "HD"
		end
	end
	tabline()
end

function M:run(t)
	local s = P[N]
	if t then
		inp "w"
	else
		t = P[N].curTest
		for i, _ in pairs(s.result) do
			s.result[i] = "PD"
		end
	end
	s.result[t] = "PD"
	tabline()
	local timer = 0
	local tle = nil
	local job = vim.fn.jobstart(
		string.format(
			"cd %s && %s < tests/%d/%d.in > tests/%d/%d.out 2> tests/%d/%d.err",
			s.problemPath,
			s.lang[3],
			t,
			t,
			t,
			t,
			t,
			t
		),
		{
			on_exit = function(_, exitCode, _)
				vim.fn.timer_stop(timer)
				if t == s.curTest then
					info(string.format("e! tests/%d/%d.err", t, t))
					out "e!"
				end
				if exitCode == 0 then
					local comp = vim.fn.jobstart(string.format("diff -qbB tests/%d/%d.out tests/%d/%d.ans", t, t, t, t), {
						on_exit = function(_, e, _)
							if e == 0 then
								s.result[t] = "AC"
							else
								s.result[t] = "WA"
							end
							tabline()
						end,
					})
				else
					if tle then
						s.result[t] = "TL"
					else
						s.result[t] = "RE"
					end
					tabline()
					if t == s.curTest then
						info(string.format("e! tests/%d/%d.err", t, t))
					end
					out "e"
				end
			end,
		}
	)
	timer = vim.fn.timer_start(s.timeout, function()
		vim.fn.jobstop(job)
		tle = 1
	end)
end

function M:compile(all)
	local s = P[N]
	if all then
		vim.cmd "wa"
	else
		main "w"
	end
	io.open(string.format("%s/.info", s.problemPath), "w"):close()
	local f = io.open(string.format("%s/.info", s.problemPath), "a")
	f:write "[Compiling...]\n"
	f:flush()
	info "e .info"
	local job = vim.fn.jobstart(s.lang[2] .. " " .. s.lang[1], {
		on_stderr = function(_, data, _)
			for _, d in ipairs(data) do
				f:write(d .. "\n")
			end
		end,
		on_exit = function(_, exitCode, _)
			if exitCode == 0 then
				f:write "[Compiled]"
				if all then
					for i, _ in pairs(s.result) do
						if s.result[i] ~= "HD" then
							run(i, 0)
						end
					end
				end
			else
				f:write "[Compile Error]"
			end
			f:close()
			info "e! .info"
		end,
	})
end

function M:open()
	vim.cmd(config.layouts[config.default_layout].cmd)
	self.win_id = vim.api.nvim_tabpage_list_wins(0)
	vim.pretty_print(self.layout)
	self:sol(config.default_lang)
	self:layout()
end

function M:new(data)
	local k, v, dir = unpack(parse_link(data.url))
	local contest_dir = path:new(dir)
	contest_dir = path:new(contest_dir:expand())
	local problem_path = contest_dir:joinpath(k, v)
	problem_path:joinpath "tests"
	problem_path:mkdir { exists_ok = true, parents = true }
	local problem_name = k .. v
	for _, p in ipairs(_G.cp_problems) do
		if p.name == problem_name then
			vim.api.nvim_set_current_tabpage(p.tab_id)
			return
		end
	end
	if #_G.cp_problems ~= 0 then
		vim.cmd "$tabnew"
	end
	local obj = {
		name = problem_name,
		path = problem_path.filename,
		tab_id = vim.api.nvim_get_current_tabpage(),
		curTest = 1,
		result = {},
	}
	setmetatable(obj, self)
	self.__index = self
	self = obj
	_G.cp_problem = obj
	table.insert(_G.cp_problems, _G.cp_problem)
	for i, test in pairs(data.tests) do
		self.result[i] = "NA"
		i = tostring(i)
		problem_path:joinpath(i):mkdir { exists_ok = true, parents = true }
		problem_path:joinpath(i, i .. ".in"):write(test.input, "w")
		problem_path:joinpath(i, i .. ".ans"):write(test.output, "w")
	end
	vim.t.cp_problem_name = problem_name
	vim.api.nvim_set_current_dir(self.path)
	self:open()
end

return M
