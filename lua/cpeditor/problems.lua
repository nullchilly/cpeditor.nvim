local M = {
	current = nil,
	list = {},
}

local path = require "plenary.path"
local config = require("cpeditor").config
local utils = require "cpeditor.utils"

function M.switch(index)
	M.current = M.list[index]
end

function M.build_test(tests)
	local problem = M.current
	for i, test in pairs(tests) do
		problem.result[i] = "NA"
		i = tostring(i)
		local test_path = config.tests_format
		path:new(utils.inter(test_path.input, { tcnum = i })):parent():mkdir { exists_ok = true, parents = true }
		path:new(utils.inter(test_path.input, { tcnum = i })):write(test.input, "w")
		path:new(utils.inter(test_path.output, { tcnum = i })):write(test.output, "w")
	end
end

function M.new(data)
	-- Build folder
	local res = nil
	for link, tab in pairs(config.links) do
		local match = (data.url):gmatch(link)
		for k, v in match do
			tab.name = utils.inter(tab.name, { m1 = k, m2 = v, name = data.name })
			tab.path = utils.inter(tab.path, { m1 = k, m2 = v, name = data.name })
			res = tab
		end
		if res then
			break
		end
	end
	if res == nil then
		vim.notify "Invalid problem"
	end
	local problem_path = path:new(res.path)
	problem_path = path:new(problem_path:expand())
	-- local problem_path = contest_dir:joinpath(k, v)
	problem_path:mkdir { exists_ok = true, parents = true }
	local problem_name = res.name

	-- Check for parsed problem
	for _, p in ipairs(M.list) do
		if p.name == problem_name then
			vim.api.nvim_set_current_tabpage(p.tab_id)
			return
		end
	end
	if #M.list ~= 0 then
		vim.cmd "$tabnew"
	end

	-- Insert to problem list
	M.current = {
		name = problem_name,
		path = problem_path.filename,
		timeout = data.timeLimit,
		curTest = 1,
		result = {},
	}
	local problem = M.current
	problem.tab_id = vim.api.nvim_get_current_tabpage()
	M.list[problem.tab_id] = M.current

	-- Cd into the problem before building tests
	vim.cmd("tcd " .. problem.path)
	M.build_test(data.tests)

	-- Setting up layout
	require("cpeditor.layout").change()
end

function M.delete(index)
	M.list[index] = nil
end

return M
