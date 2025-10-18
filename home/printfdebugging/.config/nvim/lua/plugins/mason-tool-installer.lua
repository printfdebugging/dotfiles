return {
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
        "stylua",
        "black",
      },

      auto_update = true,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 50,
    })
  end,
}
