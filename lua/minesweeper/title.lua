local glob = require("minesweeper.globals")
local M = {}

local timestring = "0s"
local markstring = "0"

local function make_title()
	local title = "Minesweeper"

	-- marks
	title = title .. " - " .. markstring

	-- time
	if glob.settings.timer then
		title = title .. " - " .. timestring
	end

	glob.border:change_title(title)
	return title
end

local function set_time(time)
	timestring = time
end

local function set_marks(mark)
	markstring = mark
end

M.set_time = set_time
M.set_marks = set_marks
M.make_title = make_title

return M
