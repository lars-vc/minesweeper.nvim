local M = {}
M.field = {}
M.buffer_number = 0
M.settings = {
	bombs = 500,
	width = 80,
	height = 40,
	borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	nerd_font = false,
}

return M
