-- Colorscheme: tokyonight remapped to the macOS 26 (Tahoe) Terminal "Clear Dark"
-- profile, so Neovim matches the system Terminal.app palette and the tmux theme.
--
-- Authoritative Clear Dark palette (decoded from the .terminal plist):
--   bg #191D27 (α0.95)  fg #E0E0E0  selection #273D4C
--                normal     bright
--   black    #35424C    #465C6D
--   red      #B45648    #DF6C5A
--   green    #6CAA71    #79BE7E
--   yellow   #C4AC62    #E5C872
--   blue     #6D96B4    #67B5ED
--   magenta  #BD7BCD    #D389E5
--   cyan     #7CCBCD    #84DDE0
--   white    #DEE5EB    #E5EFF5
--
-- transparent = true keeps the terminal's translucent/blurred background showing
-- through (same philosophy as tmux's `bg=default`). Clear Dark has no orange, so
-- `orange` is derived as a warm tone between red and yellow.

local clear_dark = {
  bg      = "#191D27",
  fg      = "#E0E0E0",
  sel     = "#273D4C",
  black   = "#35424C",
  red     = "#B45648",
  green   = "#6CAA71",
  yellow  = "#C4AC62",
  blue    = "#6D96B4",
  magenta = "#BD7BCD",
  cyan    = "#7CCBCD",
  white   = "#DEE5EB",
  br_black   = "#465C6D",
  br_red     = "#DF6C5A",
  br_green   = "#79BE7E",
  br_yellow  = "#E5C872",
  br_blue    = "#67B5ED",
  br_magenta = "#D389E5",
  br_cyan    = "#84DDE0",
  br_white   = "#E5EFF5",
  orange  = "#D98E5A", -- derived (no orange in Clear Dark)
}

return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(c)
        local p = clear_dark

        -- backgrounds / foregrounds
        c.bg           = p.bg
        c.bg_dark      = "#141821"
        c.bg_dark1     = "#0F131B"
        c.bg_highlight = "#21262F" -- CursorLine: subtler than a selection
        c.bg_visual    = p.sel
        c.bg_search    = p.sel
        c.bg_popup     = "#141821"
        c.bg_statusline = "#141821"
        c.fg           = p.fg
        c.fg_dark      = "#B9C0C8"
        c.fg_gutter    = p.black
        c.fg_sidebar   = "#B9C0C8"
        c.comment      = p.br_black
        c.black        = p.black
        c.border       = p.black -- WinSeparator -> matches tmux pane border
        c.border_highlight = p.blue -- float border -> tmux active border #6D96B4
        c.dark3        = p.br_black
        c.dark5        = "#5E7283"
        c.terminal_black = p.br_black

        -- accents
        c.blue    = p.br_blue  -- functions / primary accent
        c.blue0   = p.sel
        c.blue1   = p.blue
        c.blue2   = p.br_blue  -- info
        c.blue5   = p.br_cyan
        c.blue6   = p.br_cyan
        c.blue7   = p.sel
        c.cyan    = p.cyan
        c.teal    = p.br_cyan
        c.green   = p.green
        c.green1  = p.br_green
        c.green2  = p.green
        c.yellow  = p.yellow
        c.orange  = p.orange
        c.red     = p.br_red
        c.red1    = p.red
        c.magenta = p.magenta
        c.magenta2 = p.br_magenta
        c.purple  = p.magenta

        -- Derived roles tokyonight snapshots *before* on_colors runs, so they
        -- must be re-set here or diagnostics/git/diff keep the stock palette.
        c.error   = p.br_red
        c.warning  = p.yellow
        c.info    = p.br_blue
        c.hint    = p.br_cyan
        c.todo    = p.br_blue
        c.git = { add = p.green, change = p.blue, delete = p.red, ignore = p.br_black }
        c.rainbow = { p.br_blue, p.yellow, p.green, p.br_cyan, p.magenta, p.br_magenta, p.orange, p.red }

        -- diff backgrounds: re-blend against the Clear Dark bg
        local Util = require("tokyonight.util")
        Util.bg = p.bg
        c.diff = {
          add    = Util.blend_bg(c.green, 0.18),
          delete = Util.blend_bg(c.red, 0.18),
          change = Util.blend_bg(c.blue, 0.12),
          text   = p.sel,
        }

        -- nvim's built-in :terminal -> exact Clear Dark 16-color ANSI set
        c.terminal = {
          black = p.black,        black_bright = p.br_black,
          red = p.red,            red_bright = p.br_red,
          green = p.green,        green_bright = p.br_green,
          yellow = p.yellow,      yellow_bright = p.br_yellow,
          blue = p.blue,          blue_bright = p.br_blue,
          magenta = p.magenta,    magenta_bright = p.br_magenta,
          cyan = p.cyan,          cyan_bright = p.br_cyan,
          white = p.white,        white_bright = p.br_white,
        }
      end,
    },
  },
}
