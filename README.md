# Minesweeper.nvim
*Minesweeper in Neovim*

## How to install
### Packer
```lua
use({
    "lars-vc/minesweeper.nvim",
    config = function()
        require("minesweeper").setup({
            width = 55,  -- For custom difficulty
            height = 25, -- For custom difficulty
            bombs = 150, -- For custom difficulty
            borderchars = 
                { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- Border for the popup windows
            nerd_font = true, -- Enable if you have nerd font installed
            timer = true, -- Display the timer
        })
    end,
})
```
## Features
- Difficulties: baby, easy, medium, hard, insane or custom
- Autosolving, can be used as a hint or just watch it solve entire fields
- Color: TODO
- High stakes mode: TODO

## Launch
Start a game with `:Minesweeper DIFFICULTY` \
Can resume after closing with `:MinesweeperResume`

## Controls
```
?: Toggles the help screen
hjkl: does what you expect
w: 5 tiles forward
b: 5 tiles backward
o/f: reveal tile (works as middle click too)
i/d: place flag
r: reset field
u: undo explosion
s: get a hint from solver
p: toggle autosolver
q/Esc: quit window
```
