local path = require "plenary.path"
local config = CpConfig

local function parse_link(url)
	for link, dir in pairs(config.links) do
		for k, v in (url):gmatch(link) do
			return { k, v, dir }
		end
	end
end

function CpProblemClass:new(data)
	local k, v, dir = unpack(parse_link(data.url))
	local contest_dir = path:new(dir)
	contest_dir = path:new(contest_dir:expand())
	local problem_path = contest_dir:joinpath(k, v)
	problem_path:joinpath "tests"
	problem_path:mkdir { exists_ok = true, parents = true }
	local problem_name = k .. v
	for _, p in ipairs(CpProblemList) do
		if p.name == problem_name then
			vim.api.nvim_set_current_tabpage(p.tab_id)
			return
		end
	end
	local obj = {
		name = problem_name,
		path = problem_path.filename,
		tab_id = vim.api.nvim_get_current_tabpage(),
		timeout = data.timeLimit,
		curTest = 1,
		result = {},
	}
	setmetatable(obj, self)
	self.__index = self
	self = obj
	CpProblem = obj
	table.insert(CpProblemList, CpProblem)
	for i, test in pairs(data.tests) do
		self.result[i] = "NA"
		i = tostring(i)
		problem_path:joinpath(i):mkdir { exists_ok = true, parents = true }
		problem_path:joinpath(i, i .. ".in"):write(test.input, "w")
		problem_path:joinpath(i, i .. ".ans"):write(test.output, "w")
	end
	if #CpProblemList ~= 1 then
		vim.cmd "$tabnew"
	end
	vim.t.cp_problem_name = problem_name
	vim.cmd("tcd " .. self.path)
	self:open()
end
