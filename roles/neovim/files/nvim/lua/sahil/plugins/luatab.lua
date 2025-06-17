return {
  url = "https://codeberg.org/printfdebugging/luatab.nvim.git",
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require("luatab").setup({})
  end,
}
