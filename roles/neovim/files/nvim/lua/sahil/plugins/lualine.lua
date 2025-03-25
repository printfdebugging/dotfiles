return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "nightfly",
        section_separators = { left = "|", right = "|" },
        component_separators = { left = "|", right = "|" },
      },
      sections = {
        lualine_c = {
          {
            'tabs',
            tab_max_length = 40,
            max_length = vim.o.columns,
            mode = 1,
            path = 0,
            use_mode_colors = false,
            tabs_color = {
              active = 'lualine_c_normal',
              inactive = 'lualine_c_inactive',
            },
            show_modified_status = true,
            symbols = {
              modified = '✗',
            },
          }
        }
      }
    })
  end,
}
