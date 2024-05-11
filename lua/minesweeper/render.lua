local glob = require("minesweeper.globals")
local M = {}
local icons = {
	bomb = "",
	mark = "",
	blank = "",
	nums = {},
}
local text_icons = {
	bomb = "X",
	mark = "*",
	blank = "#",
	nums = {
		" ",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
	},
}
local nerd_icons = {
	bomb = "󰷚",
	mark = "",
	blank = "",
	nums = {
		" ",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
	},
}

M.render = function()
	local field = glob.field
	local contents = {}
	for i = 1, glob.settings.height do
		contents[i] = {}
		local line = ""
		for j = 1, glob.settings.width do
			if field[i][j].revealed then
				if field[i][j].bomb then
					line = line .. icons.bomb
				else
					line = line .. icons.nums[field[i][j].number + 1]
				end
			elseif field[i][j].marked then
				line = line .. icons.mark
			else
				line = line .. icons.blank
			end
		end
		contents[i] = line
	end

	-- local x, y, info = get_pos_w_info()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_option(glob.buffer_number, "modifiable", true)
	vim.api.nvim_buf_set_lines(glob.buffer_number, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(glob.buffer_number, "modifiable", false)
	-- set_pos_w_info(x, y, info)
	vim.api.nvim_win_set_cursor(0, pos)
end

M.use_nerd = function()
	icons = nerd_icons
end
M.use_normal = function()
	icons = text_icons
end
return M
