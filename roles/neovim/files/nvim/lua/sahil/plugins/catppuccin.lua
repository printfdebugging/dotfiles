return {

  "catppuccin/nvim",
  commit = "18bab5ec4c782cdf7d7525dbe89c60bfa02fc195",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour                = "mocha",
      transparent_background = true,
      show_end_of_buffer     = false,
      term_colors            = true,
      no_italic              = false,
      no_bold                = false,
      no_underline           = false,

      background = {
        light = "latte",
        dark  = "mocha",
      },

      dim_inactive = {
        enabled    = false,
        shade      = "dark",
        percentage = 0.15,
      },

      styles = {
        comments     = {},
        conditionals = {},
        loops        = {},
        functions    = {},
        keywords     = {},
        strings      = {},
        variables    = {},
        numbers      = {},
        booleans     = {},
        properties   = {},
        types        = {},
        operators    = {},
        misc         = {},
      },

      color_overrides        = {
        all       = {},
        frappe    = {},
        macchiato = {},
        latte     = {},
        mocha     = {
					rosewater = "#f5e0dc",
					flamingo = "#f2cdcd",
					pink = "#f5c2e7",
					mauve = "#cba6f7",
					red = "#f38ba8",
					maroon = "#eba0ac",
					peach = "#fab387",
					yellow = "#ECBE7B",
					green = "#98be65",
					teal = "#4db5bd",
					sky = "#89dceb",
					sapphire = "#74c7ec",
					blue = "#51afef",
					lavender = "#b4befe",

          text      = "#bbc2cf",
          subtext1  = "#bbc2cf",
          subtext0  = "#bbc2cf",
          overlay2  = "#bbc2cf",
          overlay1  = "#bbc2cf",
          overlay0  = "#bbc2cf",
          surface2  = "#bbc2cf",
          surface1  = "#5b6268",
          surface0  = "#2D3952",
        },
      },
      highlight_overrides    = {
      },

      integrations = {
        cmp        = true,
        gitsigns   = true,
        nvimtree   = true,
        treesitter = true,
        notify     = false,

        mini = {
          enabled           = true,
          indentscope_color = "",
        },
      },
    })

    vim.cmd.colorscheme("catppuccin")

    vim.cmd([[
      highlight TabLineSel    guifg=#1d2026 guibg=#59c2ff
      highlight TabLineFill   guibg=#00000000
      highlight TabLine       guibg=#00000000
      highlight LineNr        guifg=#d8dee9
      highlight LineNrAbove   guifg=#3f444a
      highlight LineNrBelow   guifg=#3f444a
      highlight CursorLine    guibg=#3C435E
      highlight CursorLineNr  guibg=#3C435E
      highlight Comment       guifg=#5b6268

      highlight GitSignsAddCul    guibg=#3c435e guifg=#98be65
      highlight GitSignsChangeCul guibg=#3c435e guifg=#ecb37b
      highlight GitSignsDeleteCul guibg=#3c435e guifg=#f38ba8
      highlight GitSignsChangedeleteCul guibg=#3c435e guifg=#f38ba8
      highlight GitSignsTopdeleteCul  guibg=#3c435e guifg=#f38ba8
      highlight GitSignsUntrackedCul guibg=#3c435e guifg=#98be65

      highlight Visual guibg=#3C435E guifg=none
      highlight Whitespace guifg=#2a2a2a
      highlight StatusLine guifg=#7f849c
      highlight MatchParen guibg=#00000000
      highlight lualine_tab_active guibg=#1d202600 guifg=#98be65 gui=bold
      highlight lualine_tab_inactive guibg=#1d202600 guifg=#bbc2cf
      highlight NvimTreeSC guibg=#00000000
      highlight NvimTreeStatuslineNc guibg=#00000000


      " markdown headings
      highlight @markup.heading.1.markdown guifg=#51afef gui=bold
      highlight @markup.heading.2.markdown guifg=#51afef gui=bold
      highlight @markup.heading.3.markdown guifg=#51afef gui=bold
      highlight @markup.heading.4.markdown guifg=#51afef gui=bold
      highlight @markup.heading.5.markdown guifg=#51afef gui=bold
      highlight @markup.heading.6.markdown guifg=#51afef gui=bold

      "vimdoc
      hi @label               guifg=#f5c2e7
      hi @markup.link         gui=NONE guifg=#cba6f7

    ]])
    vim.cmd([[highlight! link CursorLineSign CursorLine]])
  end,
}

