local glob = require("minesweeper.globals")
local timer = require("minesweeper.timer")
local helper = require("minesweeper.helper")
local popup = require("plenary.popup")

local M = {}

local function check_win()
	if glob.auto_solving then
		for i = 1, glob.settings.height do
			for j = 1, glob.settings.width do
				if glob.field[i][j].bomb then
					if not glob.field[i][j].marked then
						return false
					end
				elseif not glob.field[i][j].revealed then
					return false
				end
			end
		end
	else
		for i = 1, glob.settings.height do
			for j = 1, glob.settings.width do
				if not glob.field[i][j].revealed and not glob.field[i][j].bomb then
					return false
				end
			end
		end
	end
	return true
end

local function show_win_screen()
	GG = true
	glob.auto_solving = false

	local win_buffer = vim.api.nvim_create_buf(false, true)
	local win_height = 2
	local win_width = 20
	vim.api.nvim_buf_set_keymap(
		win_buffer,
		"n",
		"q",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		win_buffer,
		"n",
		"<Esc>",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)

	local _, window = popup.create(win_buffer, {
		title = "Victory!",
		highlight = "MinesweeperWindow",
		titlehighlight = "MinesweeperTitle",
		borderhighlight = "MinesweeperBorder",
		line = math.floor(((vim.o.lines - win_height) / 2) - 1),
		col = math.floor((vim.o.columns - win_width) / 2),
		minwidth = win_width,
		minheight = win_height,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	})

	vim.api.nvim_win_set_option(window.border.win_id, "winhl", "Normal:MinesweeperBorder")

	local contents = {
		"difficulty: " .. glob.difficulty,
	}
	if glob.settings.timer then
		table.insert(contents, #contents + 1, "time: " .. helper.format_time(timer.time()))
	end

	vim.api.nvim_buf_set_option(win_buffer, "modifiable", true)
	vim.api.nvim_buf_set_lines(win_buffer, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(win_buffer, "modifiable", false)
end

M.check_win = check_win
M.do_win = show_win_screen

return M
