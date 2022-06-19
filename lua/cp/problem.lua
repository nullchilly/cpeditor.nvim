local path = require "plenary.path"
local config = _G.cp_config

local function parse_link(url)
	for link, dir in pairs(config.links) do
		for k, v in (url):gmatch(link) do
			return { k, v, dir }
		end
	end
end

function Problem:new(data)
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
		self.result = "NA"
		i = tostring(i)
		problem_path:joinpath(i):mkdir { exists_ok = true, parents = true }
		problem_path:joinpath(i, i .. ".in"):write(test.input, "w")
		problem_path:joinpath(i, i .. ".ans"):write(test.output, "w")
	end
	if #_G.cp_problems ~= 1 then
		vim.cmd "$tabnew"
	end
	vim.t.cp_problem_name = problem_name
	vim.cmd("tcd " .. self.path)
	self:open()
end
