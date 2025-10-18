return {
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
}
