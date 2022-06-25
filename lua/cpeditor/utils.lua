-- http://lua-users.org/wiki/StringInterpolation
-- Pretty sure it is like O(n^2) I will improve the performance later
local function interpolation(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

local M = {}

function M.inter(str, table)
	return interpolation(str, table)
end

return M
