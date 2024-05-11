local popup = require("plenary.popup")
local M = {}

M.explode = function()
	local bomb_buffer = vim.api.nvim_create_buf(false, true)
	local exp_height = 11
	local exp_width = 27
	vim.api.nvim_buf_set_keymap(
		bomb_buffer,
		"n",
		"q",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		bomb_buffer,
		"n",
		"<Esc>",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		bomb_buffer,
		"n",
		"r",
		'<cmd>lua require("minesweeper").explosion_reset()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		bomb_buffer,
		"n",
		"u",
		'<cmd>lua require("minesweeper").undo_explosion()<CR>',
		{ noremap = true, silent = true }
	)

	GG = true
	local _, window = popup.create(bomb_buffer, {
		title = "Game Over",
		highlight = "MinesweeperWindow",
		titlehighlight = "MinesweeperTitle",
		borderhighlight = "MinesweeperBorder",
		line = math.floor(((vim.o.lines - exp_height) / 2) - 1),
		col = math.floor((vim.o.columns - exp_width) / 2),
		minwidth = exp_width,
		minheight = exp_height,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	})

	vim.api.nvim_win_set_option(window.border.win_id, "winhl", "Normal:MinesweeperBorder")

	local contents = {
		"     _.-^^---....,,--     ",
		" _--                  --_ ",
		"<                        >)",
		"|                         |",
		" \\._                   _./",
		"    ```--. . , ; .--'''   ",
		"          | |   |         ",
		"       .-=||  | |=-.   ",
		"       `-=#$%&%$#=-'   ",
		"          | ;  :|     ",
		" _____.,-#%&$@%#&#~,._____",
	}

	vim.api.nvim_buf_set_option(bomb_buffer, "modifiable", true)
	vim.api.nvim_buf_set_lines(bomb_buffer, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(bomb_buffer, "modifiable", false)
end

M.explosion_reset = function()
	vim.api.nvim_win_close(0, true)
	require("minesweeper").reset()
end

M.undo_explosion = function()
	vim.api.nvim_win_close(0, true)
	require("minesweeper").undo_bomb()
end

return M
