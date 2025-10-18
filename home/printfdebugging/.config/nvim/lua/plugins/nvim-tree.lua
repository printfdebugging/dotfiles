return {
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
        cursorline = true,
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
}
