GG = false
local popup = require("plenary.popup")
local interact = require("minesweeper.interact")
local mov = require("minesweeper.movement")
local glob = require("minesweeper.globals")
local renderer = require("minesweeper.render")
local field = glob.field

local M = {}
-- TODO:
-- open and close tab (but remember state)
-- performance improvements
-- automated solver as a screensaver
-- high stakes mode
-- color
-- timer
-- readme

local function create_window()
	glob.buffer_number = vim.api.nvim_create_buf(false, true)

	local width = glob.settings.width
	local height = glob.settings.height
	local borderchars = glob.settings.borderchars

	-- Options for the new buffer window.
	-- The window will open in the center of the current window.
	local _, tup = popup.create(glob.buffer_number, {
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
	glob.window = tup.window
	glob.border = tup.border

	vim.api.nvim_win_set_option(tup.border.win_id, "winhl", "Normal:MinesweeperBorder")

	renderer.render(math.floor(height / 2), math.floor(width / 2))
	vim.api.nvim_buf_set_option(glob.buffer_number, "modifiable", false)
	vim.api.nvim_set_current_buf(glob.buffer_number)
	return tup
end

local function new_field()
	-- Init
	for i = 1, glob.settings.height do
		field[i] = {}
		for j = 1, glob.settings.width do
			field[i][j] = { revealed = false, bomb = false, number = 0, marked = false }
		end
	end

	-- Add bombs
	local mid_i = math.floor(glob.settings.height / 2)
	local mid_j = math.floor(glob.settings.width / 2)
	for _ = 1, glob.settings.bombs do
		local bomb_i = math.random(glob.settings.height)
		local bomb_j = math.random(glob.settings.width)
		-- Protect the middle from bombs to get a safe start
		while
			(bomb_i > mid_i - 3 and bomb_i < mid_i + 3 and bomb_j > mid_j - 3 and bomb_j < mid_j + 3)
			or field[bomb_i][bomb_j].bomb
		do
			bomb_i = math.random(glob.settings.height)
			bomb_j = math.random(glob.settings.width)
		end

		field[bomb_i][bomb_j].bomb = true
		field[bomb_i][bomb_j].number = 9
	end

	-- Add numbers
	for i = 1, glob.settings.height do
		for j = 1, glob.settings.width do
			for x = -1, 1 do
				for y = -1, 1 do
					if
						i + x > 0
						and i + x <= glob.settings.height
						and j + y > 0
						and j + y <= glob.settings.width
						and field[i + x][j + y].bomb
					then
						field[i][j].number = field[i][j].number + 1
					end
				end
			end
		end
	end
end

local function init(opts)
	if opts.fargs[1] == "easy" then
		glob.settings.width = 30
		glob.settings.height = 15
		glob.settings.bombs = 30
	elseif opts.fargs[1] == "medium" then
		glob.settings.width = 55
		glob.settings.height = 25
		glob.settings.bombs = 150
	elseif opts.fargs[1] == "hard" then
		glob.settings.width = 80
		glob.settings.height = 40
		glob.settings.bombs = 500
	elseif opts.fargs[1] == "insane" then
		glob.settings.width = 175
		glob.settings.height = 45
		glob.settings.bombs = 2500
	elseif opts.fargs[1] == "custom" or opts.args[1] == nil then
	else
		print("Invalid difficulty")
		return
	end
	new_field()
	local window = create_window()

	vim.api.nvim_win_set_option(window.win_id, "number", false)
	vim.api.nvim_win_set_option(window.win_id, "relativenumber", false)
	vim.api.nvim_win_set_option(window.win_id, "cursorline", false)

	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"q",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"<Esc>",
		'<cmd>lua require("minesweeper").close_window()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"f",
		'<cmd>lua require("minesweeper").reveal()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"d",
		'<cmd>lua require("minesweeper").mark()<CR>',
		{ noremap = true, silent = true, nowait = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"o",
		'<cmd>lua require("minesweeper").reveal()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"i",
		'<cmd>lua require("minesweeper").mark()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"r",
		'<cmd>lua require("minesweeper").reset()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"w",
		'<cmd>lua require("minesweeper").wword()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"b",
		'<cmd>lua require("minesweeper").bword()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"u",
		'<cmd>lua require("minesweeper").undo_bomb()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		glob.buffer_number,
		"n",
		"?",
		'<cmd>lua require("minesweeper").show_help()<CR>',
		{ noremap = true, silent = true }
	)
end

local function reset()
	GG = false
	new_field()
	renderer.render(math.floor(glob.settings.height / 2), math.floor(glob.settings.width / 2))
end

-- Interactions => affect state
M.mark = interact.mark
M.reveal = interact.reveal
M.undo_bomb = interact.undo_bomb
-- Movement => do not affect state
M.bword = mov.bword
M.wword = mov.wword
-- Others
M.reset = reset
M.close_window = function()
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_close(win, true)
end
-- In explosion window
M.undo_explosion = require("minesweeper.explosion").undo_explosion
M.explosion_reset = require("minesweeper.explosion").explosion_reset
M.show_help = function()
	local buf = vim.api.nvim_create_buf(false, true)

	local width = 40
	local height = 14
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
		"q/Esc - close window",
		"? - show this help",
	}

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

M.minesweeper = init
-- Set the settings, if any where passed.
-- If none are passed, the default settings will be used.
-- @param opts: Plugin settings.
M.setup = function(opts)
	if opts then
		for k, v in pairs(opts) do
			glob.settings[k] = v
		end
	end

	if glob.settings.nerd_font then
		renderer.use_nerd()
	else
		renderer.use_normal()
	end

	vim.api.nvim_create_user_command("Minesweeper", function(opts)
		M.minesweeper(opts)
	end, {
		nargs = "*",
		complete = function(ArgLead, CmdLine, CursorPos)
			return { "easy", "medium", "hard", "insane", "custom" }
		end,
	})
end

return M
