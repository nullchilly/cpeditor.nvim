local M = {
	current_problem = nil,
	problemList = {},
}

local path = require "plenary.path"
local config = require("cpeditor").config

local function parse_link(url)
	for link, dir in pairs(config.links) do
		for k, v in (url):gmatch(link) do
			return { k, v, dir }
		end
	end
end

function M.switch(index)
	M.current_problem = M.problemList[index]
end

function M.new(data)
	local k, v, dir = unpack(parse_link(data.url))
	local contest_dir = path:new(dir)
	contest_dir = path:new(contest_dir:expand())
	local problem_path = contest_dir:joinpath(k, v)
	problem_path:joinpath "tests"
	problem_path:mkdir { exists_ok = true, parents = true }
	local problem_name = k .. v
	for _, p in ipairs(M.problemList) do
		if p.name == problem_name then
			vim.api.nvim_set_current_tabpage(p.tab_id)
			return
		end
	end
	M.current_problem = {
		name = problem_name,
		path = problem_path.filename,
		tab_id = vim.api.nvim_get_current_tabpage(),
		timeout = data.timeLimit,
		curTest = 1,
		result = {},
	}
	table.insert(M.problemList, M.current_problem)
	local problem = M.current_problem
	for i, test in pairs(data.tests) do
		problem.result[i] = "NA"
		i = tostring(i)
		problem_path:joinpath(i):mkdir { exists_ok = true, parents = true }
		problem_path:joinpath(i, i .. ".in"):write(test.input, "w")
		problem_path:joinpath(i, i .. ".ans"):write(test.output, "w")
	end
	if #M.problemList ~= 1 then
		vim.cmd "$tabnew"
	end
	vim.t.cp_problem_name = problem_name
	vim.cmd("tcd " .. problem.path)
	require("cpeditor.layout").open()
end

return M
