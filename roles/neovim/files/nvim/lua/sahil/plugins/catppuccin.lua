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

      color_overrides = {
        all       = {},
        frappe    = {},
        macchiato = {},
        latte     = {},

        mocha = {
          rosewater = "#839496",
          flamingo  = "#839496",
          pink      = "#839496",
          mauve     = "#839496",
          red       = "#839496",
          maroon    = "#839496",
          peach     = "#839496",
          yellow    = "#839496",
          green     = "#839496",
          teal      = "#839496",
          sky       = "#839496",
          sapphire  = "#839496",
          blue      = "#839496",
          lavender  = "#839496",

          text      = "#839496",
          subtext1  = "#839496",
          subtext0  = "#839496",
          overlay2  = "#839496",
          overlay1  = "#839496",
          overlay0  = "#839496",
          surface2  = "#839496",
          surface1  = "#2D3952",
          surface0  = "#2D3952",
        },
      },
      highlight_overrides = {
      },

      integrations = {
        cmp        = true,
        gitsigns   = true,
        nvimtree   = true,
        treesitter = false,
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
      highlight markdownH1          guifg=#839496 gui=bold
      highlight markdownH1Delimiter guifg=#839496 gui=bold
      highlight @markup.heading.1.delimiter.vimdoc guifg=#839496 gui=bold
      highlight @markup.heading.2.delimiter.vimdoc guifg=#839496 gui=bold
      highlight markdownH2 guifg=#a9a1e1 gui=bold
      highlight markdownH3 guifg=#a9a1e1 gui=bold
      highlight markdownH4 guifg=#a9a1e1 gui=bold
      highlight markdownH5 guifg=#a9a1e1 gui=bold
      highlight markdownH6 guifg=#a9a1e1 gui=bold

      highlight markdownH2Delimiter guifg=#a9a1e1 gui=bold
      highlight markdownH3Delimiter guifg=#a9a1e1 gui=bold
      highlight markdownH4Delimiter guifg=#a9a1e1 gui=bold
      highlight markdownH5Delimiter guifg=#a9a1e1 gui=bold
      highlight markdownH6Delimiter guifg=#a9a1e1 gui=bold
      highlight confComment guifg=#839496 gui=bold
      highlight @markup.link.vimdoc guifg=#a9a1e1
      highlight @label.vimdoc guifg=#a9a1e1
      highlight @variable guifg=#839496

    ]])
    vim.cmd([[highlight! link CursorLineSign CursorLine]])
  end,
}
