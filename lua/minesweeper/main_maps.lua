local M = {}
M.set_maps = function(buf)
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
		"<Esc>",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"f",
		'<cmd>lua require("minesweeper").reveal()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"d",
		'<cmd>lua require("minesweeper").mark()<CR>',
		{ noremap = true, silent = true, nowait = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"o",
		'<cmd>lua require("minesweeper").reveal()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"i",
		'<cmd>lua require("minesweeper").mark()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"r",
		'<cmd>lua require("minesweeper").reset()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"w",
		'<cmd>lua require("minesweeper").wword()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"b",
		'<cmd>lua require("minesweeper").bword()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"u",
		'<cmd>lua require("minesweeper").undo_bomb()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"?",
		'<cmd>lua require("minesweeper").show_help()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"s",
		'<cmd>lua require("minesweeper").hint()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"p",
		'<cmd>lua require("minesweeper").solve_current()<CR>',
		{ noremap = true, silent = true }
	)
end

return M
