return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = 'one-dark',
        section_separators = { left = "|", right = "|" },
        component_separators = { left = "|", right = "|" },
      }
    })
  end,
}


