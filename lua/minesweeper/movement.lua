local helper = require("minesweeper.helper")
local glob = require("minesweeper.globals")
local M = {}
M.wword = function()
	local x, y = helper.get_pos()
	if y < glob.settings.width - 5 then
		helper.set_pos(x, y + 5)
	else
		helper.set_pos(x, glob.settings.width)
	end
	helper.set_pos(x, y + 5)
end
M.bword = function()
	local x, y = helper.get_pos()
	if y > 5 then
		helper.set_pos(x, y - 5)
	else
		helper.set_pos(x, 1)
	end
end
M.begin = function()
	local x, _ = helper.get_pos()
	helper.set_pos(x, 1)
end
M.endw = function()
	local x, _ = helper.get_pos()
	helper.set_pos(x, glob.settings.width)
end
return M
