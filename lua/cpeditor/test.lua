local M = {}

local path = require "plenary.path"
local problems = require "cpeditor.problems"
local config = require("cpeditor").config
local layout = require "cpeditor.layout"
local utils = require "cpeditor.utils"

local function redraw()
	vim.cmd "redrawtabline"
end

function M.switch(t)
	local problem = problems.current
	if not problem.result[t] then
		return
	end
	layout.wincmd("err", "e! " .. utils.inter(config.tests_format.stderr, { tcnum = t }))
	layout.wincmd("inp", "e! " .. utils.inter(config.tests_format.input, { tcnum = t }))
	layout.wincmd("out", "e! " .. utils.inter(config.tests_format.output, { tcnum = t }))
	layout.wincmd("ans", "e! " .. utils.inter(config.tests_format.answer, { tcnum = t }))
	problem.curTest = t
end

function M.insert(t)
	local problem = problems.current
	problem.result[t] = "NA"
	path:new(problem.path):joinpath(t):mkdir { exists_ok = true }
	M.switch(t)
end

function M.erase(t)
	local problem = problems.current
	if not t then
		t = problem.curTest
	end
	path:new(problem.path):joinpath(t):rm()
	problem.result[t] = nil
	redraw()
end

function M.toggle(t)
	local problem = problems.current
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
	local problem = problems.current
	for t, _ in pairs(problem.result) do
		if problem.result[t] == "HD" then
			problem.result[t] = "NA"
		end
	end
	redraw()
end

function M.invert()
	local problem = problems.current
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
	local problem = problems.current
	for t, v in pairs(problem.result) do
		if v == stat then
			problem.result[t] = "HD"
		end
	end
	redraw()
end

function M.run(t)
	local problem = problems.current
	if t then
		layout.wincmd("inp", "w")
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
	local run_command = utils.inter(problem.lang.sources[problem.lang.source].run, { tcnum = t })
	local job = vim.fn.jobstart(run_command, {
		on_exit = function(_, exitCode, _)
			vim.fn.timer_stop(timer)
			if t == problem.curTest then
				layout.wincmd("err", string.format("e! tests/%d/%d.err", t, t))
				layout.wincmd("out", "e!")
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
					layout.wincmd("err", string.format("e! tests/%d/%d.err", t, t))
				end
				layout.wincmd("out", "e")
			end
		end,
	})
	timer = vim.fn.timer_start(problem.timeout, function()
		vim.fn.jobstop(job)
		tle = 1
	end)
end

function M.run_all()
	local problem = problems.current
	for i, _ in pairs(problem.result) do
		if problem.result[i] ~= "HD" then
			M.run(i)
		end
	end
end

function M.compile(all)
	local problem = problems.current
	if all then
		vim.cmd "wa"
	else
		layout.wincmd("main", "w")
	end
	io.open(string.format("%s/.err", problem.path), "w"):close()
	local f = io.open(string.format("%s/.err", problem.path), "a")
	-- TODO: change to buffer attach
	problem.status = "Compiling"
	layout.wincmd("err", "e .err")
	local compile_command = utils.inter(
		problem.lang.sources[problem.lang.source].compile,
		{ flag = problem.lang.flags[problem.lang.flag] }
	)
	print(compile_command)
	vim.fn.jobstart(compile_command, {
		on_stderr = function(_, data, _)
			for _, d in ipairs(data) do
				f:write(d .. "\n")
			end
		end,
		on_exit = function(_, exitCode, _)
			if exitCode == 0 then
				problem.status = "Compiled"
				if all then
					M.run_all()
				end
			else
				problem.status = "Compile Error"
			end
			f:close()
			layout.wincmd("err", "e! .err")
		end,
	})
end

return M
