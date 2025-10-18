return {
  "catppuccin/nvim",
  name = "catppuccin",
  commit = "8bd63e28af1791d85db2f2e22b3ce9537ad22830",
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
        conditionals = {},
        loops = {},
        functions = {},
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
            -- ["@keyword.directive"] = { fg = "#C586C0" },
            -- ["@keyword.import"] = { fg = "#C586C0" },
            -- ["@function.method"] = { fg = mocha.blue },
            -- ["@function.cpp"] = { fg = mocha.blue },
            -- ["@function.call"] = { fg = mocha.blue },
            -- ["@function.method.call"] = { fg = mocha.blue },
            -- ["@constructor"] = { fg = mocha.blue },
            -- ["@constant"] = { fg = mocha.peach },
            -- ["@operator"] = { fg = mocha.blue },
            -- ["@keyword.type"] = { fg = mocha.blue },
            ["@comment"] = { fg = "#5B6268" },
            -- ["@string"] = { fg = "#CE9178" },
            ["@markup.heading.1.markdown"] = { fg = mocha.blue, style = { "bold" } },
            ["@markup.heading.2.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.3.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.4.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.5.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.heading.6.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
            ["@markup.link.label"] = { fg = mocha.blue, style = { "bold", "underline" } },
            RenderMarkdownH1Bg = { fg = mocha.blue, bg = "#282c34", style = { "bold" } },
            RenderMarkdownH2Bg = { fg = "#A9A1E1", bg = "#282c34", style = { "bold" } },
            RenderMarkdownH3Bg = { fg = "#A9A1E1", bg = "#282c34", style = { "bold" } },
            RenderMarkdownH4Bg = { fg = "#A9A1E1", bg = "#282c34", style = { "bold" } },
            RenderMarkdownH5Bg = { fg = "#A9A1E1", bg = "#282c34", style = { "bold" } },
            RenderMarkdownH6Bg = { fg = "#A9A1E1", bg = "#282c34", style = { "bold" } },
            RenderMarkdownCode = { bg = "#21242b" },
            RenderMarkdownCodeInline = { bg = "#21242b" },
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
        highlight TabLineSel    guifg=#00222b guibg=#59c2ff
        highlight TabLineFill   guibg=#00000000
        highlight TabLine       guibg=#00000000
        highlight LineNr        guifg=#d8dee9
        highlight LineNrAbove   guifg=#3f444a
        highlight LineNrBelow   guifg=#3f444a
        highlight CursorLine    guibg=#21242b
        highlight CursorLineNr  guibg=#21242b
        highlight GitSignsAddCul guibg=#21242b guifg=#98be65
        highlight GitSignsChangeCul guibg=#21242b guifg=#ecb37b
        highlight GitSignsDeleteCul guibg=#21242b guifg=#f38ba8
        highlight GitSignsChangedeleteCul guibg=#21242b guifg=#f38ba8
        highlight GitSignsTopdeleteCul guibg=#21242b guifg=#f38ba8
        highlight GitSignsUntrackedCul guibg=#21242b guifg=#98be65
        highlight Visual               guibg=#3f444a guifg=none gui=bold
        highlight @function.builtin   guifg=#51afef
        highlight @markup.link    gui=NONE guifg=#51afef gui=underline
        highlight @label    gui=NONE guifg=#cba6f7 gui=underline
        highlight Comment             guifg=#5B6268
        highlight CmpNormal           guibg=#21242b
        highlight NormalFloat         guibg=#00000000
        highlight FloatFooter guibg=#00000000
        highlight FloatTitle  guibg=#00000000
        highlight FloatBorder guibg=#00000000
        highlight TelescopeSelection guibg=#00000000
        highlight TelescopeSelectionCaret guibg=#00000000
        highlight QuickFixLine guibg=#3f444a gui=BOLD
        highlight TreesitterContextBottom gui=none guibg=#21242b
        highlight TreesitterContext gui=none guibg=#21242b
        highlight TreesitterContextLineNumberBottom gui=none guifg=#3f444a guibg=#21242b
        highlight TreesitterContextLineNumber gui=none guifg=#3f444a guibg=#21242b
        highlight Whitespace guifg=#2D3952
        highlight @markup.raw guifg=#a9a1e1
        ]])
    vim.cmd([[highlight! link CursorLineSign CursorLine]])
  end,
}
