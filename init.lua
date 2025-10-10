---@diagnostic disable: param-type-mismatch, undefined-global, duplicate-set-field, lowercase-global
vim.deprecate = function() end

--------------- options ---------------------
local options = {
  relativenumber = true,
  number = true,
  fixendofline = false,
  ruler = false,
  cmdheight = 1,
  background = "dark",
  fillchars = "fold: ",
  tabstop = 4,
  shiftwidth = 4,
  expandtab = true,
  autoindent = true,
  syntax = "on",
  wrap = false,
  ignorecase = true,
  smartcase = true,
  cursorline = false,
  termguicolors = true,
  signcolumn = "yes",
  backspace = "indent,eol,start",
  splitright = true,
  splitbelow = true,
  pumheight = 12,
  conceallevel = 3,
  guicursor = "a:block",
  hlsearch = true,
  incsearch = true,
  scrolloff = 5,
  updatetime = 50,
  scroll = 4,
  showtabline = 2,
  concealcursor = "ncv",
  formatprg = "par w70",
  splitkeep = "screen",
  equalalways = true,
}

local globals = {
  noswapfile = true,
  nobackup = true,
  nowritebackup = true,
  laststatus = 3,
  mapleader = " ",
  editorconfig_max_line_length = 100,
}

vim.opt.fillchars = { eob = " " }
vim.opt.clipboard:append("unnamedplus")

for key, value in pairs(options) do
  vim.opt[key] = value
end

for key, value in pairs(globals) do
  vim.g[key] = value
end

------------------ plugins ------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

require("lazy").setup({

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            n = { ["<C-q>"] = actions.send_to_loclist + actions.open_loclist },
            i = { ["<C-q>"] = actions.send_to_loclist + actions.open_loclist },
          },
          layout_strategy = "vertical",
          layout_config = {
            bottom_pane = {
              height = 20,
              preview_cutoff = 0.5,
              prompt_position = "top",
            },
            center = {
              height = 0.4,
              preview_cutoff = 0.5,
              prompt_position = "top",
              width = 0.9,
            },
            cursor = {
              height = 0.9,
              preview_cutoff = 0.5,
              width = 0.8,
            },
            horizontal = {
              height = 0.9,
              preview_cutoff = 0.5,
              preview_width = 0.6,
              prompt_position = "bottom",
              width = 0.9,
            },
            vertical = {
              height = 200,
              width = 0.9,
              preview_cutoff = 20,
              prompt_position = "bottom",
              -- width = 0.8,
            },
          },
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
      })
    end,
  },

  {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup({
        outline_window = {
          position = "left",
          split_command = nil,
          width = 25,
          relative_width = true,
          auto_close = false,
          auto_jump = true,
          jump_highlight_duration = 300,
          center_on_jump = true,
          show_numbers = false,
          show_relative_numbers = false,
          wrap = false,
          show_cursorline = false,
          hide_cursor = false,
          focus_on_open = true,
          winhl = "",
          no_provider_message = "No supported provider...",
        },
        outline_items = {
          show_symbol_details = true,
          show_symbol_lineno = false,
          highlight_hovered_item = true,
          auto_set_cursor = true,
          auto_update_events = {
            follow = { "CursorMoved" },
            items = { "InsertLeave", "WinEnter", "BufEnter", "BufWinEnter", "TabEnter", "BufWritePost" },
          },
        },
        guides = {
          enabled = true,
          markers = {
            bottom = "└",
            middle = "├",
            vertical = "│",
          },
        },
        symbol_folding = {
          autofold_depth = 1,
          auto_unfold = {
            hovered = true,
            only = true,
          },
          markers = { "", "" },
        },
        preview_window = {
          auto_preview = false,
          open_hover_on_preview = false,
          width = 100,
          min_width = 100,
          relative_width = true,
          height = 50,
          min_height = 10,
          relative_height = true,
          border = "single",
          winhl = "NormalFloat:",
          winblend = 0,
          live = false,
        },
        keymaps = {
          show_help = "?",
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          peek_location = "o",
          goto_and_close = "<S-Cr>",
          restore_location = "<C-g>",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_toggle = "<Tab>",
          fold_toggle_all = "<S-Tab>",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
          down_and_jump = "<C-j>",
          up_and_jump = "<C-k>",
        },
        providers = {
          priority = { "lsp", "coc", "markdown", "norg", "man" },
          lsp = {
            blacklist_clients = {},
          },
          markdown = {
            filetypes = { "markdown" },
          },
        },
        symbols = {
          filter = nil,
          icon_fetcher = nil,
          icon_source = nil,
          icons = {
            File = { icon = "󰈔", hl = "Identifier" },
            Module = { icon = "󰆧", hl = "Include" },
            Namespace = { icon = "󰅪", hl = "Include" },
            Package = { icon = "󰏗", hl = "Include" },
            Class = { icon = "𝓒", hl = "Type" },
            Method = { icon = "ƒ", hl = "Function" },
            Property = { icon = "", hl = "Identifier" },
            Field = { icon = "󰆨", hl = "Identifier" },
            Constructor = { icon = "", hl = "Special" },
            Enum = { icon = "ℰ", hl = "Type" },
            Interface = { icon = "󰜰", hl = "Type" },
            Function = { icon = "", hl = "Function" },
            Variable = { icon = "", hl = "Constant" },
            Constant = { icon = "", hl = "Constant" },
            String = { icon = "𝓐", hl = "String" },
            Number = { icon = "#", hl = "Number" },
            Boolean = { icon = "⊨", hl = "Boolean" },
            Array = { icon = "󰅪", hl = "Constant" },
            Object = { icon = "⦿", hl = "Type" },
            Key = { icon = "🔐", hl = "Type" },
            Null = { icon = "NULL", hl = "Type" },
            EnumMember = { icon = "", hl = "Identifier" },
            Struct = { icon = "𝓢", hl = "Structure" },
            Event = { icon = "🗲", hl = "Type" },
            Operator = { icon = "+", hl = "Identifier" },
            TypeParameter = { icon = "𝙏", hl = "Identifier" },
            Component = { icon = "󰅴", hl = "Function" },
            Fragment = { icon = "󰅴", hl = "Constant" },
            TypeAlias = { icon = " ", hl = "Type" },
            Parameter = { icon = " ", hl = "Identifier" },
            StaticMethod = { icon = " ", hl = "Function" },
            Macro = { icon = " ", hl = "Function" },
          },
        },
      })
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        float_opts = {
          border = "curved",
        },
      })
      function _G.set_terminal_keymaps()
        local opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<S-Space>", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
      end
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },

  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        auto_install = true, -- don't automatically install the parsers
        ensure_installed = {
          "c",
          "cpp",
          "markdown",
          "markdown_inline",
          "diff",
          "lua",
          "vim",
          "vimdoc",
          "go",
          "gitcommit",
          "python",
          "java",
          "bash",
          "html",
          "yaml",
          "ini",
          "toml",
        },
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = false,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "nvim-treesitter/playground",
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {}, -- this is equalent to setup({}) function
  },

  {
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
      highlight TreesitterContextBottom gui=none guibg=#1d2126
      highlight TreesitterContext gui=none guibg=#1d2126
      highlight TreesitterContextLineNumberBottom gui=none guifg=#3f444a
      highlight TreesitterContextLineNumber gui=none guifg=#3f444a
      ]])
      vim.cmd([[highlight! link CursorLineSign CursorLine]])
    end,
  },

  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup({
        opleader = {
          line = "gc",
          block = "gb",
        },
      })
    end,
  },

  {
    "krady21/compiler-explorer.nvim",
    config = function()
      require("compiler-explorer").setup({
        url = "https://godbolt.org",
        infer_lang = true, -- Try to infer possible language based on file extension.
        line_match = {
          highlight = true, -- highlight the matching line(s) in the other buffer.
          jump = true, -- move the cursor in the other buffer to the first matching line.
        },
        open_qflist = false, --  Open qflist after compilation if there are diagnostics.
        split = "split", -- How to split the window after the second compile (split/vsplit).
        compiler_flags = "", -- Default flags passed to the compiler.
        job_timeout_ms = 25000, -- Timeout for libuv job in milliseconds.
        languages = { -- Language specific default compiler/flags
          c = {
            compiler = "g121",
            compiler_flags = "",
          },
        },
      })
    end,
  },

  {
    "jghauser/follow-md-links.nvim",
  },

  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          python = { "isort", "black" },
          sh = { "shfmt" },
        },
        -- format_on_save = {
        -- 	lsp_format = "fallback",
        -- 	timeout_ms = 500,
        -- },
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          local current_file_path = vim.fn.expand("%:p")
          local excluded_strings = {
            "online",
            "core",
          }
          for _, str in ipairs(excluded_strings) do
            if string.match(current_file_path, str) then
              return
            end
          end
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        culhl = true,
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
      })
    end,
  },

  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = false,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    commit = "29be0919b91fb59eca9e90690d76014233392bef",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        exclude = { filetypes = { "norg" } },
        whitespace = {
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      })
    end,
  },

  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        relative_to_current_file = true,
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          section_separators = { left = "|", right = "|" },
          component_separators = { left = "|", right = "|" },
        },
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      local ls = require("luasnip")

      local s = ls.snippet
      local i = ls.insert_node
      local f = ls.function_node
      local fmt = require("luasnip.extras.fmt").fmt

      ls.add_snippets("help", {
        s(
          "heading",
          fmt(
            [[
				    --------------------------------------------------------------------------------
				    *<>*
				    ]],

            {
              i(1, "heading"),
            },
            { delimiters = "<>" }
          )
        ),

        s(
          "title",
          fmt("*<>*", {
            f(function(_, snip)
              return vim.fn.expand("%:t")
            end, {}),
          }, {
            delimiters = "<>",
          })
        ),

        s(
          "codeblock",
          fmt(
            [[
>{}
    {}
<
				    ]],
            {
              i(1),
              i(2),
            },
            {
              delimiters = "{}",
            }
          )
        ),
      })
    end,
  },

  {
    "alvarosevilla95/luatab.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("luatab").setup({})
    end,
  },

  {
    -- Install markdown preview, use npx if available.
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function(plugin)
      if vim.fn.executable("npx") then
        vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
      else
        vim.cmd([[Lazy load markdown-preview.nvim]])
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      if vim.fn.executable("npx") then
        vim.g.mkdp_filetypes = { "markdown" }
      end
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- formatters and linters
          "shellcheck",
          "shfmt",
          "stylua",
          "black",
        },

        auto_update = true,
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 50,
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "rust_analyzer",
          "clangd",
          "cmake",
          "glsl_analyzer",
          "pyright",
          "gopls",
          "ts_ls",
          "html",
          "ansiblels",
          "marksman",
          "bashls",
          "cssls",
          "emmet_ls",
        },
      })
    end,
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({ auto_install = true })
    end,
  },

  {
    "NeogitOrg/neogit",
    tag = "v0.0.1",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("neogit").setup({
        highlight = {
          italic = false,
          bold = false,
          underline = false,
        },
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",

      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "nvimdev/lspsaga.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        view = { docs = { auto_open = false } },
        window = {
          completion = {
            scrollbar = false,
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
        }),

        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 20,
            ellipsis_char = "...",

            before = function(_, vim_item)
              vim_item.menu = ({ nvim_lsp = "" })["clangd"]
              return vim_item
            end,
          }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" }, -- For luasnip users.
          { name = "buffer" },
          { name = "path" },
        }),
      })
      require("lspsaga").setup({
        ui = {
          border = "single",
          code_action = "",
        },
        definition = {
          keys = {
            quit = "q",
          },
        },
        lightbulb = {
          virtual_text = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
      })
      -- Set up lspconfig.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = {
        "clangd",
        "cmake",
        "glsl_analyzer",
        "ts_ls",
        "lua_ls",
        "ansiblels",
        "cmake",
        "html",
        "cssls",
        "pyright",
        "bashls",
        "gopls",
        "emmet_ls",
        "marksman",
      }

      for _, server in ipairs(servers) do
        require("lspconfig")[server].setup({
          capabilities = capabilities,
        })
      end

      require("lspconfig")["rust_analyzer"].setup({
        capabilities = capabilities,
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
      })

      require("lspconfig")["lua_ls"].setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      })
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
  },

  {
    "szw/vim-maximizer",
  },

  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local my_on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set("n", "<C-i>", api.tree.change_root_to_node, opts("CD"))
        vim.keymap.set("n", "<C-o>", api.tree.change_root_to_parent, opts("CD"))
      end

      require("nvim-tree").setup({
        on_attach = my_on_attach,
        sync_root_with_cwd = true,
        view = {
          cursorline = false,
          width = 35,
          side = "left",
        },
        renderer = {
          root_folder_label = false,
          icons = {
            glyphs = {
              folder = {
                arrow_closed = "", -- arrow when folder is closed
                arrow_open = "", -- arrow when folder is open
              },
            },
          },
        },

        actions = {
          open_file = {
            window_picker = {
              enable = false,
            },
          },
        },
      })
    end,
  },
})

------------------ keymaps -------------------

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end
      return vim.tbl_flatten({
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      })
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "Multi Grep",
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end

-- resume the last string search
local builtin = require("telescope.builtin")
function telescope_resume()
  if G_telescope_last == 0 then
    G_telescope_last = 1
    live_multigrep()
  else
    builtin.resume()
  end
end
G_telescope_last = 0

-- prefer man(3) pages
function show_man_page()
  local name = vim.fn.input("man: ")
  if name == "" then
    return
  end

  if pcall(vim.cmd, "tab Man 3p" .. name) then
    return
  end
  if pcall(vim.cmd, "tab Man " .. name) then
    return
  end
end

-- don't close the first tab
function custom_tabclose()
  if vim.fn.tabpagenr() == 1 then
    print("You cannot close the first tab!")
  else
    vim.cmd("tabclose")
  end
end

function timelog_entry()
  local date_time_stamp = vim.fn.system('date "+%F %r"')
  local journal_dir = os.getenv("JOURNAL_DIR") or os.getenv("HOME")
  local log_file_path = journal_dir .. "/timelog.txt"
  date_time_stamp = string.gsub(date_time_stamp, "\n", "")
  local log = vim.fn.input("log: ")
  if log == "" then
    return
  end
  vim.fn.system('echo "' .. date_time_stamp .. ": " .. log .. '" >> ' .. log_file_path)
  vim.notify("")
end

function man_or_hover_doc()
  local word_under_cursor = vim.fn.expand("<cword>")
  if word_under_cursor == "" then
    return
  end
  if pcall(vim.cmd, "tab Man 3p" .. word_under_cursor) then
    return
  end
  if pcall(vim.cmd, "tab Man " .. word_under_cursor) then
    return
  end
  vim.cmd("Lspsaga hover_doc")
end

function follow_wiki_link()
  -- get the current word under cursor
  local word = vim.fn.expand("<cword>")
  if word == nil then
    print("word under cursor nil")
    return
  end

  -- check if a link exists
  local ok = pcall(vim.cmd, "helptags .")
  if not ok then
    print("helptags failed ")
    return
  end

  ok = pcall(vim.cmd, "tag " .. word)
  if ok then
    print("found tag " .. word)
    return
  end

  -- link destination
  local sep = package.config:sub(1, 1)
  local date = os.date("%Y" .. sep .. "%m")
  local path = date .. sep .. word

  if vim.fn.filereadable(path) == 0 then
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    local file = io.open(path, "w")
    if file then
      file:write("*" .. word .. "*\n\n\n")
      file:write("vim:tw=70:ts=4:sw=4:et:ft=help:norl:iskeyword+=-,.:")
      file:close()
    end
  end
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

vim.g.mapleader = " "

local normal_mode_leader_keymaps = {
  { "w", ":w!<CR>" },
  { "q", ":q!<CR>" },
  { "e", ":NvimTreeFindFileToggle!<CR>" },
  { "y", ':"+y' },
  { "Y", ':"+Y' },
  { "D", ":Lspsaga show_line_diagnostics<CR>" },
  { "d", ":Lspsaga show_cursor_diagnostics<CR>" },
  { "1", ':lua require("harpoon.ui").nav_file(1)<CR>' },
  { "2", ':lua require("harpoon.ui").nav_file(2)<CR>' },
  { "3", ':lua require("harpoon.ui").nav_file(3)<CR>' },
  { "4", ':lua require("harpoon.ui").nav_file(4)<CR>' },
  { "5", ':lua require("harpoon.ui").nav_file(5)<CR>' },

  { "oo", ":Outline<CR>" },
  { "nh", ":nohlsearch<CR>" },
  { "mp", ":MarkdownPreviewToggle<CR>" },
  { "ca", ":Lspsaga code_action<CR>" },
  { "rn", ":Lspsaga rename<CR>" },
  { "ff", ":lua G_telescope_last=0 require('telescope.builtin').find_files()<CR>" },
  { "fh", ":lua G_telescope_last=0 require('telescope.builtin').help_tags()<CR>" },
  { "gs", ":lua G_telescope_last=1 require('telescope.builtin').git_status()<CR>" },
  { "ls", ":Telescope buffers<CR>" },
  { "fb", ":lua G_telescope_last=0 require('telescope.builtin').current_buffer_fuzzy_find()<CR>" },
  { "fs", telescope_resume },
  { "mm", ':lua require("harpoon.mark").add_file()<CR>' },
  { "gt", ":Gitsigns toggle_deleted<CR>" },
  { "gn", ":Gitsigns next_hunk<CR>" },
  { "gp", ":Gitsigns prev_hunk<CR>" },
  { "gx", ":Gitsigns reset_hunk<CR>" },
  { "rr", ":MdEvalClean<CR>" },
  { "sv", ":vsplit<CR>" },
  { "sh", ":split<CR>" },
  { "tx", ":tabclose<CR>" },
  { "tn", ":tabn<CR>" },
  { "tc", ":tabnew<CR>" },
  { "tp", ":tabp<CR>" },
  { "rs", ":LspRestart<CR>" },
  { "oe", ":lua vim.diagnostic.open_float()<CR>" },
  { "gh", ':lua require("neogit").open()<CR>' },
  { "fm", show_man_page },
}

local normal_mode_keymaps = {
  { "t", timelog_entry },
  {
    "<C-a>",
    function()
      local pwd = vim.fn.getcwd()
      if vim.uv.fs_stat(pwd .. "/CMakeLists.txt") then
        vim.cmd([[
          :cgetexpr systemlist('cmake -B build && make -C build')
          :copen
        ]])
      elseif vim.uv.fs_stat(pwd .. "/Makefile") or vim.uv.fs_stat(pwd .. "/makefile") then
        vim.cmd([[
          :cgetexpr systemlist('make')
          :copen
        ]])
      else
        print("ERROR: neither CMakeLists.txt nor Makefile found")
      end
    end,
  },
  {
    "<C-s>",
    function()
      local pwd = vim.fn.getcwd()
      if vim.uv.fs_stat(pwd .. "/CMakeLists.txt") then
        vim.cmd([[
          :cgetexpr systemlist('make -C build run')
          :copen
        ]])
      elseif vim.uv.fs_stat(pwd .. "/Makefile") or vim.uv.fs_stat(pwd .. "/makefile") then
        vim.cmd([[
          :cgetexpr systemlist('make run')
          :copen
        ]])
      else
        print("ERROR: neither CMakeLists.txt nor Makefile found")
      end
    end,
  },
  {
    "<C-d>",
    function()
      local pwd = vim.fn.getcwd()
      if vim.uv.fs_stat(pwd .. "/CMakeLists.txt") then
        vim.cmd([[
          :cgetexpr systemlist('rm -rf build')
          :copen
        ]])
      elseif vim.uv.fs_stat(pwd .. "/Makefile") or vim.uv.fs_stat(pwd .. "/makefile") then
        vim.cmd([[
          :cgetexpr systemlist('make clean')
          :copen
        ]])
      else
        print("ERROR: neither CMakeLists.txt nor Makefile found")
      end
    end,
  },
  { "m", ":MaximizerToggle!<CR>" },
  { "m", ":MaximizerToggle!<CR>" },
  { "z", ":ToggleTerm<CR>" },
  { "J", "mzJ`z" },
  { "s", ":source %<CR>" },
  { "<", ":-tabmove<CR>" },
  { ">", ":+tabmove<CR>" },
  { "K", man_or_hover_doc },
  { "gf", ":Lspsaga lsp_finder<CR>" },
  { "gD", ":Lspsaga peek_definition<CR>" },
  { "gd", ":Lspsaga goto_definition<CR>" },
  { "gi", ":lua vim.lsp.buf.implementation()<CR>" },
  { "[d", ":Lspsaga diagnostic_jump_prev<CR>" },
  { "]d", ":Lspsaga diagnostic_jump_next<CR>" },
  { "gr", ":lua vim.lsp.buf.references()<CR>" },
  { "<C-n>", ":cnext<CR>" },
  { "<C-p>", ":cprev<CR>" },
  { "<M-n>", ":lnext<CR>" },
  { "<M-p>", ":lprev<CR>" },
  { "<C-e>", ':lua require("harpoon.ui").toggle_quick_menu()<CR>' },
  { "<C-t>", ":tabnew<CR>" },
  { "<C-q>", custom_tabclose },
  { "<C-S-T>", ":tab split<CR>" },
  { "<C-1>", "1gt<CR>" },
  { "<C-2>", "2gt<CR>" },
  { "<C-3>", "3gt<CR>" },
  { "<C-4>", "4gt<CR>" },
  { "<C-5>", "5gt<CR>" },
  { "<C-6>", "6gt<CR>" },
  { "<C-7>", "7gt<CR>" },
}

local keymaps_with_mode = {
  { "x", "p", '"_dP' },
  { "v", "J", ":m '>+1<CR>gv=gv" },
  { "v", "K", ":m '<-2<CR>gv=gv" },
  { "v", "<leader>y", '"+y' },
  {
    { "i", "s" },
    "<M-l>",
    function()
      require("luasnip").jump(1)
    end,
  },
  {
    { "i", "s" },
    "<M-h>",
    function()
      require("luasnip").jump(-1)
    end,
  },
}

for _, map in pairs(normal_mode_leader_keymaps) do
  vim.keymap.set("n", "<leader>" .. map[1], map[2])
end

for _, map in pairs(normal_mode_keymaps) do
  vim.keymap.set("n", map[1], map[2])
end

for _, map in pairs(keymaps_with_mode) do
  vim.keymap.set(map[1], map[2], map[3])
end

----------------------- autocmds ---------------------------

vim.cmd([[
  augroup NoCursorLine
  autocmd!
  autocmd FileType toggleterm setlocal nocursorline nonumber norelativenumber
  autocmd FileType cmake_tools_terminal setlocal nocursorline nonumber norelativenumber
  augroup END
]])

vim.cmd("set autoread")
vim.cmd("set laststatus=3")

local markdown_no_warnings = vim.api.nvim_create_augroup("CppFormatingWithClangd", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  group = markdown_no_warnings,
  callback = function(args)
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = args.buf,
      group = markdown_no_warnings,
      callback = function()
        vim.diagnostic.config({ virtual_text = false })
      end,
    })
  end,
})

vim.api.nvim_create_user_command("Help", function(opts)
  vim.cmd("tab help " .. opts.args)
end, { nargs = "*" })

vim.api.nvim_create_autocmd("Filetype", {
  pattern = { "help" },
  callback = function()
    vim.keymap.set("n", "<leader>oo", follow_wiki_link)
  end,
})
