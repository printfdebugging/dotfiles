return {
  "catppuccin/nvim",
  commit = "18bab5ec4c782cdf7d7525dbe89c60bfa02fc195",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      no_italic = false,
      no_bold = false,
      no_underline = false,
      styles = {
        comments = {},
        conditionals = { "bold" },
        loops = {},
        functions = { "bold" },
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        misc = {},
      },
      color_overrides = {
        all = {},
        mocha = {
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
          text = "#d8dee9",
          subtext1 = "#bac2de",
          subtext0 = "#a6adc8",
          overlay2 = "#9399b2",
          overlay1 = "#7f849c",
          overlay0 = "#5B6268",
          surface2 = "#676E95",
          surface1 = "#6C7085",
          surface0 = "#2D3952",
          -- base = "#676E95",
          -- mantle = "#181825",
          -- crust = "#11111b",
        },
        frappe = {},
        macchiato = {},
        latte = {},
      },
      highlight_overrides = {
        mocha = function(mocha)
          return {
            -- ["@function.cpp"] = { fg = mocha.blue },
            -- ["@function.method.call"] = { fg = mocha.blue },
            -- ["@constructor"] = { fg = mocha.blue },
            -- ["@constant"] = { fg = mocha.peach },
            -- ["@operator"] = { fg = mocha.blue },
            ["@comment"] = { fg = "#676E95" },
            ["@keyword.import"] = { fg = "#cba6f7", style = { "bold" } },
            ["@keyword.directive"] = { fg = "#cba6f7", style = { "bold" } },
            ["@keyword.directive.define"] = { fg = "#f5c2e7", style = { "bold" } },
            ["@constant"] = { fg = "#fab387", style = { "bold" } },
            ["@constant.builtin"] = { fg = "#cba6f7", style = { "bold" } },
            -- ["@function.call"] = { fg = mocha.blue },
            -- ["@function.method"] = { fg = mocha.blue },
            ["@markup.heading.1.markdown"] = { fg = mocha.blue, style = { "bold" } },
            ["@markup.heading.2.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.3.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.4.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.5.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.6.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.link.label"] = { fg = mocha.blue, style = { "bold", "underline" } },
          }
        end,
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    })

    vim.cmd.colorscheme("catppuccin")

    vim.cmd([[
      highlight TabLineSel    guifg=#242b38 guibg=#59c2ff
      highlight TabLineFill   guibg=#00000000
      highlight TabLine       guibg=#00000000
      highlight LineNr        guifg=#d8dee9
      highlight LineNrAbove   guifg=#3f444a
      highlight LineNrBelow   guifg=#3f444a
      highlight CursorLine    guibg=#3C435E
      highlight CursorLineNr  guibg=#3C435E

      highlight GitSignsAddCul guibg=#3c435e guifg=#98be65
      highlight GitSignsChangeCul guibg=#3c435e guifg=#ecb37b
      highlight GitSignsDeleteCul guibg=#3c435e guifg=#f38ba8
      highlight GitSignsChangedeleteCul guibg=#3c435e guifg=#f38ba8
      highlight GitSignsTopdeleteCul guibg=#3c435e guifg=#f38ba8
      highlight GitSignsUntrackedCul guibg=#3c435e guifg=#98be65

      highlight Visual guibg=#3C435E guifg=none
      highlight Whitespace guifg=#2a2a2a
      highlight MatchParen guibg=#00000000
    ]])
    vim.cmd([[highlight! link CursorLineSign CursorLine]])
  end,
}
