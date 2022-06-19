local path = require "plenary.path"
local config = CpConfig

local function redraw()
	vim.cmd "redrawtabline"
end

function CpProblemClass:test(t)
	if not self.result[t] then
		return
	end
	self:wincmd("err", string.format("e! tests/%d/%d.err", t, t))
	self:wincmd("inp", string.format("e! tests/%d/%d.in", t, t))
	self:wincmd("out", string.format("e! tests/%d/%d.out", t, t))
	self:wincmd("ans", string.format("e! tests/%d/%d.ans", t, t))
	self.curTest = t
end

function CpProblemClass:insert(t)
	self.result[t] = "NA"
	path:new(self.path):joinpath(t):mkdir({exists_ok = true})
	CpProblemClass:test(t)
end

function CpProblemClass:erase(t)
	if not t then
		t = self.curTest
	end
	path:new(self.path):joinpath(t):rm()
	self.result[t] = nil
	redraw()
end

function CpProblemClass:hide_show(t)
	if not t then
		t = self.curTest
	end
	if self.result[t] == "HD" then
		self.result[t] = "NA"
	else
		self.result[t] = "HD"
	end
	redraw()
end

function CpProblemClass:show_all()
	for t, _ in pairs(self.result) do
		if self.result[t] == "HD" then
			self.result[t] = "NA"
		end
	end
	redraw()
end

function CpProblemClass:invert()
	for t, _ in pairs(self.result) do
		if self.result[t] == "HD" then
			self.result[t] = "NA"
		else
			self.result[t] = "HD"
		end
	end
	redraw()
end

function CpProblemClass:hide(stat)
	for t, v in pairs(self.result) do
		if v == stat then
			self.result[t] = "HD"
		end
	end
	redraw()
end

function CpProblemClass:run(t)
	if t then
		self:wincmd("inp", "w")
	else
		t = self.curTest
		for i, _ in pairs(self.result) do
			self.result[i] = "PD"
		end
	end
	self.result[t] = "PD"
	redraw()
	local timer = 0
	local tle = nil
	local job = vim.fn.jobstart(
		string.format(
			"cd %s && %s < tests/%d/%d.in > tests/%d/%d.out 2> tests/%d/%d.err",
			self.problemPath, self.lang[3], t, t, t, t, t, t), {
			on_exit = function(_, exitCode, _)
				vim.fn.timer_stop(timer)
				if t == self.curTest then
					self:wincmd("err", string.format("e! tests/%d/%d.err", t, t))
					self:wincmd("out", "e!")
				end
				if exitCode == 0 then
					vim.fn.jobstart(string.format("diff -qbB tests/%d/%d.out tests/%d/%d.ans", t, t, t, t), {
						on_exit = function(_, comp, _)
							if comp == 0 then
								self.result[t] = "AC"
							else
								self.result[t] = "WA"
							end
							redraw()
						end,
					})
				else
					if tle then
						self.result[t] = "TL"
					else
						self.result[t] = "RE"
					end
					redraw()
					if t == self.curTest then
						self:wincmd("err", string.format("e! tests/%d/%d.err", t, t))
					end
					self:wincmd("out", "e")
				end
			end,
		}
	)
	timer = vim.fn.timer_start(self.timeout, function()
		vim.fn.jobstop(job)
		tle = 1
	end)
end

function CpProblemClass:compile(all)
	if all then
		vim.cmd "wa"
	else
		self:wincmd("main", "w")
	end
	io.open(string.format("%s/.err", self.path), "w"):close()
	local f = io.open(string.format("%s/.err", self.path), "a")
	-- TODO: change to buffer attach
	f:write "[Compiling...]\n"
	f:flush()
	self:wincmd("err", "e .err")
	vim.fn.jobstart(self.lang[2] .. " " .. self.lang[1], {
		on_stderr = function(_, data, _)
			for _, d in ipairs(data) do
				f:write(d .. "\n")
			end
		end,
		on_exit = function(_, exitCode, _)
			if exitCode == 0 then
				f:write "[Compiled]"
				if all then
					for i, _ in pairs(self.result) do
						if self.result[i] ~= "HD" then
							self:run(i)
						end
					end
				end
			else
				f:write "[Compile Error]"
			end
			f:close()
			self:wincmd("err", "e! .err")
		end
	})
end
