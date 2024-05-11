GG = false
local popup = require("plenary.popup")
local explosion = require("minesweeper.explosion")
local glob = require("minesweeper.globals")
local renderer = require("minesweeper.render")
local helper = require("minesweeper.helper")
local field = glob.field

local M = {}
-- TODO:
-- nerdfont
-- show remaining bomb count
-- better bomb generation
--- difficulty levels
-- open and close tab (but remember state)
-- performance improvements
-- automated solver as a screensaver
-- center cursor on open


local function open_window()
    glob.buffer_number = vim.api.nvim_create_buf(false, true)

    local width = glob.settings.width
    local height = glob.settings.height
    local borderchars = glob.settings.borderchars

    -- Options for the new buffer window.
    -- The window will open in the center of the current window.
    local _, window = popup.create(glob.buffer_number, {
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

    vim.api.nvim_win_set_option(window.border.win_id, "winhl", "Normal:MinesweeperBorder")

    renderer.render()
    vim.api.nvim_buf_set_option(glob.buffer_number, "modifiable", false)
    vim.api.nvim_set_current_buf(glob.buffer_number)
    -- vim.api.nvim_win_set_cursor(window.win_id, { header_to_start_on, 0 })
end

local function new_field()
    math.randomseed(os.time())
    -- Init
    for i = 1, glob.settings.height do
        field[i] = {}
        for j = 1, glob.settings.width do
            field[i][j] = { revealed = false, bomb = false, number = 0, marked = false }
        end
    end

    -- Add bombs
    for _ = 1, glob.settings.bombs do
        local bomb_i = math.random(glob.settings.height)
        local bomb_j = math.random(glob.settings.width)

        field[bomb_i][bomb_j].bomb = true
        field[bomb_i][bomb_j].number = 5
    end

    -- Add numbers
    for i = 1, glob.settings.height do
        for j = 1, glob.settings.width do
            for x = -1, 1 do
                for y = -1, 1 do
                    if i + x > 0
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

local function init()
    new_field()
    open_window()

    vim.api.nvim_win_set_option(0, "number", false)
    vim.api.nvim_win_set_option(0, "relativenumber", false)
    vim.api.nvim_win_set_option(0, "cursorline", false)

    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "q",
        '<cmd>lua require("minesweeper").close_window()<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "<Esc>",
        '<cmd>lua require("minesweeper").close_window()<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "o",
        '<cmd>lua require("minesweeper").reveal()<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "i",
        '<cmd>lua require("minesweeper").mark()<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "r",
        '<cmd>lua require("minesweeper").reset()<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "w",
        '<cmd>lua require("minesweeper").wword()<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        0,
        "n",
        "u",
        '<cmd>lua require("minesweeper").undo_bomb()<CR>',
        { noremap = true, silent = true }
    )
end

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
        renderer.render()
    end
end

local function mark()
    if not GG then
        local x, y = helper.get_pos()

        if not field[x][y].revealed then
            field[x][y].marked = not field[x][y].marked
        end

        -- render new state
        renderer.render()
    end
end

local function reset()
    GG = false
    new_field()
    renderer.render()
end

M.mark = mark
M.reset = reset
M.reveal = reveal
M.close_window = function()
    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_close(win, true)
end

M.wword = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    if glob.settings.nerd_font then
        pos[2] = pos[2] + 15
    else
        pos[2] = pos[2] + 5
    end
    vim.api.nvim_win_set_cursor(0, pos)
end
M.bword = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    if glob.settings.nerd_font then
        pos[2] = pos[2] - 15
    else
        pos[2] = pos[2] - 5
    end
    vim.api.nvim_win_set_cursor(0, pos)
end

M.undo_bomb = function()
    for i = 1, glob.settings.height do
        for j = 1, glob.settings.width do
            if field[i][j].bomb then
                field[i][j].revealed = false
            end
        end
    end
    GG = false
    print("Undid explosion")
    renderer.render()
end

M.undo_explosion = require("minesweeper.explosion").undo_explosion
M.explosion_reset = require("minesweeper.explosion").explosion_reset

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

    vim.api.nvim_create_user_command("Minesweeper", function()
        M.minesweeper()
    end, {})
end

return M
