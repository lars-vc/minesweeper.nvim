local glob = require("minesweeper.globals")
local M = {}
M.get_pos = function()
	local tup = vim.api.nvim_win_get_cursor(0)
	local x = tup[1]
	local y = tup[2]
	-- nerd font is 3 columns wide, since we use a mix of normal and nerd we need to check this
	-- I assume revealed is normal font, otherwise nerd
	if glob.settings.nerd_font then
		local i = 1
		while i <= y do
			if not glob.field[x][i].revealed then
				y = y - 2
			else
				i = i + 2
			end
			i = i + 1
		end
	end
	y = y + 1

	return x, y
end
local function get_pos_w_info()
	local tup = vim.api.nvim_win_get_cursor(0)
	local x = tup[1]
	local y = tup[2]
	-- nerd font is 3 columns wide, since we use a mix of normal and nerd we need to check this
	-- I assume revealed is normal font, otherwise nerd
	local nerd_count = 0
	if glob.settings.nerd_font then
		local i = 1
		local tot = y
		while i <= tot do
			if not glob.field[x][i].revealed then
				y = y - 2
				nerd_count = nerd_count + 1
			else
				i = i + 2
			end
			i = i + 1
		end
		y = y + 1
	end

	return x, y, nerd_count
end

local function set_pos_w_info(x, y, nerd_count)
	if glob.settings.nerd_font then
		local i = 1
		local new_count = 0
		local tot = y
		while i <= tot do
			if not glob.field[x][i].revealed then
				y = y + 2
				new_count = new_count + 1
			else
				i = i + 2
			end
			i = i + 1
		end
		print(nerd_count, new_count)
		y = y - (nerd_count - new_count) * 3
	end
	print(y)

	vim.api.nvim_win_set_cursor(0, { x, y })
end

return M
