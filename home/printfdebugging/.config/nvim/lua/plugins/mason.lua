return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup({ auto_install = true })
  end,
}
