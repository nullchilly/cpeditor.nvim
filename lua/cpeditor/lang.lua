local M = {}
local config = require("cpeditor").config
local problems = require "cpeditor.problems"
local layout = require "cpeditor.layout"

function M.set(lang)
	local problem = problems.current
	problem.lang = config.langs[lang]
	layout.wincmd("main", "e! " .. problem.lang.source)
	layout.wincmd("err", "e! .err | set ft=" .. lang)
end

return M
