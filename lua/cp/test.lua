local M = {}

local path = require "plenary.path"
local problems = require "cp.problems"
local layout = require "cp.layout"
local config = require("cp").config

local function redraw()
	vim.cmd "redrawtabline"
end

function M.switch(t)
	local problem = problems.current_problem
	if not problem.result[t] then
		return
	end
	layout.wincmd("err", string.format("e! tests/%d/%d.err", t, t))
	layout.wincmd("inp", string.format("e! tests/%d/%d.in", t, t))
	layout.wincmd("out", string.format("e! tests/%d/%d.out", t, t))
	layout.wincmd("ans", string.format("e! tests/%d/%d.ans", t, t))
	problem.curTest = t
end

function M.insert(t)
	local problem = problems.current_problem
	problem.result[t] = "NA"
	path:new(problem.path):joinpath(t):mkdir { exists_ok = true }
	M.switch(t)
end

function M.erase(t)
	local problem = problems.current_problem
	if not t then
		t = problem.curTest
	end
	path:new(problem.path):joinpath(t):rm()
	problem.result[t] = nil
	redraw()
end

function M.toggle(t)
	local problem = problems.current_problem
	if not t then
		t = problem.curTest
	end
	if problem.result[t] == "HD" then
		problem.result[t] = "NA"
	else
		problem.result[t] = "HD"
	end
	redraw()
end

function M.show_all()
	local problem = problems.current_problem
	for t, _ in pairs(problem.result) do
		if problem.result[t] == "HD" then
			problem.result[t] = "NA"
		end
	end
	redraw()
end

function M.invert()
	local problem = problems.current_problem
	for t, _ in pairs(problem.result) do
		if problem.result[t] == "HD" then
			problem.result[t] = "NA"
		else
			problem.result[t] = "HD"
		end
	end
	redraw()
end

function M.hide(stat)
	local problem = problems.current_problem
	for t, v in pairs(problem.result) do
		if v == stat then
			problem.result[t] = "HD"
		end
	end
	redraw()
end

function M.run(t)
	local problem = problems.current_problem
	if t then
		M.wincmd("inp", "w")
	else
		t = problem.curTest
		for i, _ in pairs(problem.result) do
			problem.result[i] = "PD"
		end
	end
	problem.result[t] = "PD"
	redraw()
	local timer = 0
	local tle = nil
	local job = vim.fn.jobstart(string.format("cd %s && %s < tests/%d/%d.in > tests/%d/%d.out 2> tests/%d/%d.err", problem.problemPath, self.lang[3], t, t, t, t, t, t), {
		on_exit = function(_, exitCode, _)
			vim.fn.timer_stop(timer)
			if t == problem.curTest then
				M.wincmd("err", string.format("e! tests/%d/%d.err", t, t))
				M.wincmd("out", "e!")
			end
			if exitCode == 0 then
				vim.fn.jobstart(string.format("diff -qbB tests/%d/%d.out tests/%d/%d.ans", t, t, t, t), {
					on_exit = function(_, comp, _)
						if comp == 0 then
							problem.result[t] = "AC"
						else
							problem.result[t] = "WA"
						end
						redraw()
					end,
				})
			else
				if tle then
					problem.result[t] = "TL"
				else
					problem.result[t] = "RE"
				end
				redraw()
				if t == problem.curTest then
					M.wincmd("err", string.format("e! tests/%d/%d.err", t, t))
				end
				M.wincmd("out", "e")
			end
		end,
	})
	timer = vim.fn.timer_start(problem.timeout, function()
		vim.fn.jobstop(job)
		tle = 1
	end)
end

function M.compile(all)
	local problem = problems.current_problem
	if all then
		vim.cmd "wa"
	else
		M.wincmd("main", "w")
	end
	io.open(string.format("%s/.err", problem.path), "w"):close()
	local f = io.open(string.format("%s/.err", problem.path), "a")
	-- TODO: change to buffer attach
	f:write "[Compiling...]\n"
	f:flush()
	M.wincmd("err", "e .err")
	vim.fn.jobstart(problem.lang[2] .. " " .. self.lang[1], {
		on_stderr = function(_, data, _)
			for _, d in ipairs(data) do
				f:write(d .. "\n")
			end
		end,
		on_exit = function(_, exitCode, _)
			if exitCode == 0 then
				f:write "[Compiled]"
				if all then
					for i, _ in pairs(problem.result) do
						if problem.result[i] ~= "HD" then
							M.run(i)
						end
					end
				end
			else
				f:write "[Compile Error]"
			end
			f:close()
			M.wincmd("err", "e! .err")
		end,
	})
end

return M
