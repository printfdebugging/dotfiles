return {
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
}
