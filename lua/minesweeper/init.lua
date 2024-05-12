GG = false
local popup = require("plenary.popup")
local interact = require("minesweeper.interact")
local mov = require("minesweeper.movement")
local glob = require("minesweeper.globals")
local renderer = require("minesweeper.render")
local solver = require("minesweeper.autosolver")
local show_help = require("minesweeper.help_popup")
local timer = require("minesweeper.timer")
local mapper = require("minesweeper.main_maps")

local field = glob.field
local M = {}
-- TODO:
-- open and close tab (but remember state)
-- performance improvements
-- high stakes mode
-- color
-- timer
-- readme
-- proper win screen
-- improve solver (there are solvable cases which currently are not found)

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
	if glob.settings.timer then
		timer.start()
	end
	vim.api.nvim_win_set_option(tup.win_id, "number", false)
	vim.api.nvim_win_set_option(tup.win_id, "relativenumber", false)
	vim.api.nvim_win_set_option(tup.win_id, "cursorline", false)

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

	timer.reset()
end

local function init(opts)
	if opts.fargs[1] == "baby" then
		glob.settings.width = 30
		glob.settings.height = 15
		glob.settings.bombs = 5
	elseif opts.fargs[1] == "easy" then
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

	GG = false
	new_field()
	create_window()

	mapper.set_maps(glob.buffer_number)
end

M.minesweeper_resume = function()
	if field == {} then
		init()
		return
	end
	create_window()
	mapper.set_maps(glob.buffer_number)
end

local function reset()
	print("Reset the field")
	GG = false
	new_field()
	renderer.render(math.floor(glob.settings.height / 2), math.floor(glob.settings.width / 2))
	timer.reset()
	timer.start()
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
	timer.stop()
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_close(win, true)
end
M.hint = solver.hint
M.solve_current = solver.solve_current
-- In explosion window
M.undo_explosion = require("minesweeper.explosion").undo_explosion
M.explosion_reset = require("minesweeper.explosion").explosion_reset

M.show_help = show_help.help_popup
M.autosolve = solver.solve
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

	vim.api.nvim_create_user_command("Minesweeper", function(opt)
		M.minesweeper(opt)
	end, {
		nargs = "*",
		complete = function(ArgLead, CmdLine, CursorPos)
			return { "baby", "easy", "medium", "hard", "insane", "custom" }
		end,
	})
	vim.api.nvim_create_user_command("MinesweeperResume", function(opt)
		M.minesweeper_resume(opt)
	end, {})

	vim.api.nvim_create_user_command("MinesweeperSolve", function(opt)
		glob.auto_solving = true
		M.minesweeper(opt)
		M.autosolve()
	end, {
		nargs = "*",
	})
end

return M
