local M = {}
local path = require("plenary.path")
local problems = _G.cp_problems
local config = _G.cp_config

function M:new(data)
	for link, dir in pairs(config.links) do
		for k, v in (data.url):gmatch(link) do
			print(k, v)
			local contest_dir = path:new(dir)
			contest_dir:expand()
			local problem_path = contest_dir:joinpath(k, v)
			problem_path:joinpath("tests")
			problem_path:mkdir({ exists_ok = true, parents = true })
			local problem_name = k .. v
			for i, test in pairs(data.tests) do
				i = tostring(i)
				problem_path:joinpath(i):mkdir({ exists_ok = true, parents = true })
        problem_path:joinpath(i, i .. ".in"):write(test.input, "w")
        problem_path:joinpath(i, i .. ".ans"):write(test.output, "w")
			end
			_G.cp_cur_problem = _G.cp_cur_problem + 1
			if _G.cp_cur_problem ~= 1 then
				vim.cmd "$tabnew"
			end
			vim.t.cp_problem_name = problem_name
			problems[_G.cp_cur_problem] = {
				name = problem_name,
				path = problem_path.filename,
				curTest = 1,
				tests_result = { "NA", "WA", "AC" }
			}
			require("cp.layout").tab(_G.cp_cur_problem)
			require("cp.layout"):open()
		end
	end
end

return M
