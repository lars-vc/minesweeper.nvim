local glob = require("minesweeper.globals")
local title = require("minesweeper.title")
local helper = require("minesweeper.helper")
local win = require("minesweeper.win")

local M = {}

local icons = {
	bomb = "",
	mark = "",
	blank = "",
	nums = {},
}
local text_icons = {
	bomb = "X",
	mark = "!",
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

M.render = function(x, y)
	if x == nil and y == nil then
		x, y = helper.get_pos()
	end
	local field = glob.field
	local contents = {}
	local marks = 0
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
				marks = marks + 1
			else
				line = line .. icons.blank
			end
		end
		contents[i] = line
	end

	title.set_marks("" .. glob.settings.bombs - marks)
	title.make_title()
	vim.api.nvim_buf_set_option(glob.buffer_number, "modifiable", true)
	vim.api.nvim_buf_set_lines(glob.buffer_number, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(glob.buffer_number, "modifiable", false)
	if not GG then
		helper.set_pos(x, y)
	end

	if win.check_win() then
		win.do_win()
	end
end

M.use_nerd = function()
	icons = nerd_icons
end
M.use_normal = function()
	icons = text_icons
end
return M
