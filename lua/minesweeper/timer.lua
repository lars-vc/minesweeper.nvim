local title = require("minesweeper.title")
local helper = require("minesweeper.helper")
local M = {}
local time = 0
local timer = nil
local function start_timer()
	timer = vim.loop.new_timer()
	timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			time = time + 1
			if GG and timer ~= nil then
				timer:close()
				timer = nil
			else
				title.set_time(helper.format_time(time))
				title.make_title()
			end
		end)
	)
end

local function stop_timer()
	if timer ~= nil then
		timer:close()
	end
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
