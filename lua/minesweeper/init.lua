local popup = require("plenary.popup")

local M = {}

-- Default options for the floating window.
local settings = {
	bombs = 10,
	width = 60,
	height = 10,
	borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	popup_auto_close = true, -- or false
}
local field = {}

-- Open a popup window with the headers of the current buffer.
-- The buffer itself is not modifiable.
-- @param header_to_start_on: Line number of the header to set the cursor on, inside the popup window.
local function open_window()
	local buffer = vim.api.nvim_create_buf(false, true)

	local width = settings.width
	local height = settings.height
	local borderchars = settings.borderchars

	-- Options for the new buffer window.
	-- The window will open in the center of the current window.
	local _, window = popup.create(buffer, {
		title = "Minesweeper",
		highlight = "MinesweeperWindow",
		titlehighlight = "MinesweeperTitle",
		borderhighlight = "MinesweeperBorder",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})
	for i = 1, height do
		field[i] = {}
		for j = 1, width do
			field[i][j] = 0
		end
	end

	vim.api.nvim_win_set_option(window.border.win_id, "winhl", "Normal:MinesweeperBorder")

	local contents = {}
	for i = 1, height do
		contents[i] = {}
		for j = 1, width do
			contents[i][j] = field[i][j]
		end
	end
	--
	vim.api.nvim_buf_set_lines(buffer, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(buffer, "modifiable", false)
	vim.api.nvim_set_current_buf(buffer)
	-- vim.api.nvim_win_set_cursor(window.win_id, { header_to_start_on, 0 })
end

M.close_window = function()
	local win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_close(win, true)
end

M.minesweeper = function(start_on_closest)
	open_window()

	vim.api.nvim_win_set_option(0, "number", false)
	vim.api.nvim_win_set_option(0, "relativenumber", false)
	vim.api.nvim_win_set_option(0, "cursorline", false)

	-- Map the enter key to select the header.
	-- Map q and escape to close the window.
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<CR>",
		':lua require("md-headers").select_header()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"q",
		':lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<Esc>",
		':lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
end

-- Set the settings, if any where passed.
-- If none are passed, the default settings will be used.
-- @param opts: Plugin settings.
M.setup = function(opts)
	if opts then
		for k, v in pairs(opts) do
			settings[k] = v
		end
	end

	vim.api.nvim_create_user_command("Minesweeper", function()
		M.minesweeper()
	end, {})
end

return M
