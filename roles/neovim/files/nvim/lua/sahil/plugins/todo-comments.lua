return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    keywords = {
      PIN = {
        color = "hint",
        icon = "📍", -- icon used for the sign, and in search results
        -- signs = false, -- configure signs for some keywords individually
      },
    },
    search = {
      pattern = [[PIN: \d{2}]],
      sorted_quickfix = true,
    },
  },
}
