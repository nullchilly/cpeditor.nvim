local M = {}
local config = require("cpeditor").config

function M.sol(L)
	problem.lang = config.langs[L]
	problem:wincmd("main", "e! " .. self.lang.main[1])
	problem:wincmd("err", "e! .err | set ft=" .. L)
end

return M
