local popup = require("plenary.popup")
local glob = require("minesweeper.globals")
local M = {}
local function help_popup()
	local buf = vim.api.nvim_create_buf(false, true)

	local contents = {
		"Movement:",
		"hjkl - what you expect",
		"wb - 5 tiles back/forward",
		"^$ - begin or end of line",
		"",
		"Interact:",
		"o/f - reveal tile (also middle click)",
		"i/d - place flag",
		"r - reset field",
		"u - undo explosion (cheater)",
		"",
		"Others:",
		"s - get a hint",
		"p - toggle auto solve",
		"q/Esc - close window",
		"? - show this help",
	}

	local width = 40
	local height = #contents
	local borderchars = glob.settings.borderchars

	-- Options for the new buffer window.
	-- The window will open in the center of the current window.
	local _, tup = popup.create(buf, {
		title = "Help",
		highlight = "MinesweeperWindow",
		titlehighlight = "MinesweeperTitle",
		borderhighlight = "MinesweeperBorder",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	vim.api.nvim_win_set_option(tup.border.win_id, "winhl", "Normal:MinesweeperBorder")

	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_lines(buf, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"?",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
end

M.help_popup = help_popup
return M
