local title = require("minesweeper.title")
local glob = require("minesweeper.globals")
local helper = require("minesweeper.helper")

local M = {}

local time = 0
local timer = nil

local function stop_timer()
	if timer ~= nil then
		timer:close()
		timer = nil
	end
end

local function start_timer()
	timer = vim.loop.new_timer()
	timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			time = time + 1
			local win = vim.api.nvim_get_current_win()
			if win == glob.win_id then
				if GG then
					stop_timer()
				else
					title.set_time(helper.format_time(time))
					title.make_title()
				end
			else
				stop_timer()
			end
		end)
	)
end

local function reset_timer()
	time = 0
end

local function get_time()
	return time
end

M.start = start_timer
M.stop = stop_timer
M.reset = reset_timer
M.time = get_time

return M
