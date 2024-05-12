local M = {}
local renderer = require("minesweeper.render")
local helper = require("minesweeper.helper")
local glob = require("minesweeper.globals")
local explosion = require("minesweeper.explosion")
local field = glob.field

local function reveal_zero(x, y)
    if not field[x][y].revealed and not field[x][y].marked then
        -- stack based to avoid recursive stack overflow
        local stack = { { x, y } }
        local visited = { { x, y } }
        while #stack > 0 do
            local pos = table.remove(stack)
            if not field[pos[1]][pos[2]].revealed then
                field[pos[1]][pos[2]].revealed = true
                if field[pos[1]][pos[2]].number == 0 then
                    for x2 = -1, 1 do
                        for y2 = -1, 1 do
                            if pos[1] + x2 > 0
                                and pos[1] + x2 <= glob.settings.height
                                and pos[2] + y2 > 0
                                and pos[2] + y2 <= glob.settings.width
                                and not field[pos[1] + x2][pos[2] + y2].marked
                            then
                                for _, v in ipairs(visited) do
                                    if v[1] == pos[1] + x2 and v[2] == pos[2] + y2 then
                                        goto continue
                                    end
                                end
                                table.insert(stack, { pos[1] + x2, pos[2] + y2 })
                                table.insert(visited, { pos[1] + x2, pos[2] + y2 })
                                ::continue::
                            end
                        end
                    end
                end
            end
        end
    end
end

-- TODO: check if x2 and y2 are both zero, then dont do iter
local function reveal_pos(x, y, rec)
    if rec == nil then
        rec = false
    end

    if field[x][y].marked then
        return
    end

    if field[x][y].bomb then
        field[x][y].revealed = true
        explosion.explode()
        return
    end
    if not rec and field[x][y].revealed then
        local marked = 0
        for x2 = -1, 1 do
            for y2 = -1, 1 do
                if x + x2 > 0
                    and x + x2 <= glob.settings.height
                    and y + y2 > 0
                    and y + y2 <= glob.settings.width
                    and field[x + x2][y + y2].marked
                then
                    marked = marked + 1
                end
            end
        end
        if marked >= field[x][y].number then
            for x2 = -1, 1 do
                for y2 = -1, 1 do
                    if x + x2 > 0
                        and x + x2 <= glob.settings.height
                        and y + y2 > 0
                        and y + y2 <= glob.settings.width
                        and not field[x + x2][y + y2].marked
                    then
                        if field[x + x2][y + y2].number == 0 then
                            reveal_zero(x + x2, y + y2)
                        else
                            reveal_pos(x + x2, y + y2, true)
                        end
                    end
                end
            end
        end
    else

        if field[x][y].number == 0 then
            reveal_zero(x, y)
        else
            field[x][y].revealed = true
        end
    end
end

local function reveal()
    if not GG then
        local x, y = helper.get_pos()

        -- reveal and update state
        reveal_pos(x, y, false)

        -- render new state
        renderer.render(x, y)
    end
end

local function mark()
    if not GG then
        local x, y = helper.get_pos()

        if not field[x][y].revealed then
            field[x][y].marked = not field[x][y].marked
        end

        -- render new state
        renderer.render(x, y)
    end
end

local function undo_bomb()
    local x, y = helper.get_pos()
    for i = 1, glob.settings.height do
        for j = 1, glob.settings.width do
            if field[i][j].bomb then
                field[i][j].revealed = false
            end
        end
    end
    GG = false
    print("Undid explosion")
    renderer.render(x, y)
end

M.mark = mark
M.reveal = reveal
M.reveal_pos = reveal_pos
M.undo_bomb = undo_bomb

return M
