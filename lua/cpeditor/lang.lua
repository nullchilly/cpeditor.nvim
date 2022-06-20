local M = {}
local config = require("cpeditor").config
local problems = require "cpeditor.problems"
local layout = require "cpeditor.layout"

function M.set(L)
	local problem = problems.current_problem
	problem.lang = config.langs[L]
	layout.wincmd("main", "e! " .. problem.lang.main[1])
	layout.wincmd("err", "e! .err | set ft=" .. L)
end

return M
