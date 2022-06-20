local M = {}
local config = require("cpeditor").config
local problems = require "cpeditor.problems"
local layout = require "cpeditor.layout"

function M.set(lang)
	local problem = problems.current_problem
	problem.lang = config.langs[lang]
	layout.wincmd("main", "e! " .. problem.lang.main[1])
	layout.wincmd("err", "e! .err | set ft=" .. lang)
end

return M
