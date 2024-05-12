local title = require("minesweeper.title")
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
			if GG then
				timer:close()
				timer = nil
			else
				local sec = time % 60
				local min = time / 60
				local hour = min / 60
				min = min % 60
				local timestring = string.format("%02d:%02d:%02d", hour, min, sec)
				title.set_time(timestring)
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

M.start = start_timer
M.stop = stop_timer
M.reset = reset_timer
return M
