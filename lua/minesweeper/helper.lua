local glob = require("minesweeper.globals")
local M = {}

local function is_nerd(x, y)
	return not glob.field[x][y].revealed or glob.field[x][y].bomb
end

-- get the position of the cursor converted to field coordinates
M.get_pos = function()
	local tup = vim.api.nvim_win_get_cursor(0)
	local x = tup[1]
	local y = tup[2]
	if glob.settings.nerd_font then
		local i = 1
		local tot = y
		while i < tot + 1 do
			if is_nerd(x, i) then
				tot = tot - 2
			end
			i = i + 1
		end
		y = i
		-- y = y - (nerd_count - 1) * 2
	else
		y = y + 1
	end

	return x, y
end

-- set the position of the cursor given field coordinates
M.set_pos = function(x, y)
	local w = y
	local nerd_count = 0
	if glob.settings.nerd_font then
		local i = 1
		while i <= y - 1 do
			if is_nerd(x, i) then
				nerd_count = nerd_count + 1
			end
			i = i + 1
		end
		y = y + nerd_count * 2
	end
	y = y - 1
	vim.api.nvim_win_set_cursor(0, { x, y })
end

return M
