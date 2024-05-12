local M = {}
M.field = {}
M.buffer_number = 0
M.settings = {
	width = 55,
	height = 25,
	bombs = 150,
	borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	nerd_font = true,
	timer = true,
}
M.window = {}
M.border = {}
M.auto_solving = false

return M
