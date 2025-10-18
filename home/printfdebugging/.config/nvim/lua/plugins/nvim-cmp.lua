return {
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
}
