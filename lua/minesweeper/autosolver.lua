local glob = require("minesweeper.globals")
local interaction = require("minesweeper.interact")
local helper = require("minesweeper.helper")
local M = {}
local field = glob.field
local timer = nil

local function solve_iter()
	local height = glob.settings.height
	local width = glob.settings.width
	for i = 1, height do
		for j = 1, width do
			if field[i][j].revealed then
				local marked = 0
				local hidden = 0
				local did_action = false
				-- collect info on neighbors
				for x2 = -1, 1 do
					for y2 = -1, 1 do
						if
							i + x2 > 0
							and i + x2 <= glob.settings.height
							and j + y2 > 0
							and j + y2 <= glob.settings.width
						then
							if field[i + x2][j + y2].marked then
								marked = marked + 1
							end
							if not field[i + x2][j + y2].revealed and not field[i + x2][j + y2].marked then
								hidden = hidden + 1
							end
						end
					end
				end

				-- 1. check if the number of marked neighbors is equal to the number of the cell
				-- 1. if so reveal all neighbors
				if marked == field[i][j].number then
					for x2 = -1, 1 do
						for y2 = -1, 1 do
							if
								i + x2 > 0
								and i + x2 <= glob.settings.height
								and j + y2 > 0
								and j + y2 <= glob.settings.width
								and not field[i + x2][j + y2].marked
								and not field[i + x2][j + y2].revealed
							then
								helper.set_pos(i + x2, j + y2)
								interaction.reveal()
								did_action = true
							end
						end
					end
				end

				-- 2. check if the number of hidden neighbors is equal to the number of the cell - already marked
				-- 2. if so mark all hidden neighbors
				if hidden == field[i][j].number - marked then
					for x2 = -1, 1 do
						for y2 = -1, 1 do
							if
								i + x2 > 0
								and i + x2 <= glob.settings.height
								and j + y2 > 0
								and j + y2 <= glob.settings.width
								and not field[i + x2][j + y2].marked
								and not field[i + x2][j + y2].revealed
							then
								helper.set_pos(i + x2, j + y2)
								interaction.mark()
								did_action = true
							end
						end
					end
				end
				-- do one action per iteration for satifying animation
				if did_action then
					return true
				end
			end
		end
	end
	return false
end

local function solve()
	-- reveal the center
	local height = glob.settings.height
	local width = glob.settings.width
	helper.set_pos(math.floor(height / 2), math.floor(width / 2))
	interaction.reveal()

	timer = vim.loop.new_timer()
	-- iter the solve
	timer:start(
		0,
		50,
		vim.schedule_wrap(function()
			if not solve_iter() or not glob.auto_solving then
				glob.auto_solving = false
				if timer ~= nil then
					timer:close()
					timer = nil
				end
			end
		end)
	)
end

local function solve_current()
	if glob.auto_solving then
		glob.auto_solving = false
	else
		glob.auto_solving = true
		solve()
	end
end

local function hint()
	if not solve_iter() then
		print("No hint available")
	end
end

local stop_solving = function()
	glob.auto_solving = false
	if timer ~= nil then
		timer:close()
		timer = nil
	end
end

M.solve_current = solve_current
M.solve = solve
M.hint = hint
M.stop_solving = stop_solving

return M
