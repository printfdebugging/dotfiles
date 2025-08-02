return	{
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function ()
    local my_on_attach = function (bufnr)
      local api = require "nvim-tree.api"
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- custom mappings
      vim.keymap.set("n", "<C-i>", api.tree.change_root_to_node,          opts("CD"))
      vim.keymap.set("n", "<C-o>", api.tree.change_root_to_parent,          opts("CD"))
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

    -- local function open_nvim_tree(data)
      -- 	-- buffer is a [No Name]
      -- 	local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
      --
      -- 	-- buffer is a directory
      -- 	local directory = vim.fn.isdirectory(data.file) == 1
      --
      -- 	if not no_name and not directory then
      -- 		return
      -- 	end
      --
      -- 	-- change to the directory
      -- 	if directory then
      -- 		vim.cmd.cd(data.file)
      -- 	end
      --
      -- 	-- open the tree
      -- 	require("nvim-tree.api").tree.open()
      -- end
      --
      -- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

    end
  }

