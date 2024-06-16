require("sahil.core.options")

require("sahil.plugins.lazy")
require("sahil.plugins.plugin-configs.telescope")
require("sahil.plugins.plugin-configs.catppuccin")
require("sahil.plugins.plugin-configs.nvim-treesitter")
require("sahil.plugins.plugin-configs.nvim-tree")
require("sahil.plugins.plugin-configs.toggle-term")
require("sahil.plugins.plugin-configs.comment")
require("sahil.plugins.plugin-configs.neogit")

-- LSP and COMPLETIONS
require("sahil.plugins.plugin-configs.LuaSnip")
require("sahil.plugins.plugin-configs.nvim-cmp")
require("sahil.plugins.plugin-configs.mason-lspconfig")
require("sahil.plugins.plugin-configs.nullls")
require("sahil.plugins.plugin-configs.gitsigns")
require("sahil.plugins.plugin-configs.nvim-dap")
require("sahil.plugins.plugin-configs.nvim-dap-ui")
require("sahil.plugins.plugin-configs.nvim-dap-virt-text")
-- Although image previewing works, it works only in kitty, and the text
-- blurring in kitty is just unacceptable. I am switching back to st.
require("sahil.plugins.plugin-configs.nvim-dap-go")

require("sahil.core.keymaps")
require("sahil.core.autocmds")
