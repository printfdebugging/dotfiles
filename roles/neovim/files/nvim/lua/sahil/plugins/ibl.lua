return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  commit = "29be0919b91fb59eca9e90690d76014233392bef",
  config = function()
    require("ibl").setup({
      indent = { char = "│" },
      exclude = { filetypes = { "markdown", "conf" } },
      whitespace = {
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    })
  end,
}
