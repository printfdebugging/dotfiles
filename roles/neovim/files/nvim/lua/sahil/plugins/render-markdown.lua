return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  opts = {},
  config = function ()
    require('render-markdown').setup({
      render_modes = { 'n', 'no', 'nov', 'c', 't', 'i', 'o', 'V', 'v' },

      overrides = {
        buftype = {
          nofile = {
            enabled = false,
          },
        },
      },

      heading = {
        enabled = false,
        render_modes = false,
        sign = false,
      },

      code = {
        enabled = true,
        render_modes = false,
        sign = false,
        language_name = true,
        disable_background = {},
        width = 'full',
        border = 'thick',
      },

      bullet       = { enabled = false },
      checkbox     = { enabled = false },
      html         = { enabled = false },
      link         = { enabled = false },
      pipe_table   = { enabled = false },

      win_options = {
        conceallevel = {
          default = vim.api.nvim_get_option_value('conceallevel', {}),
          rendered = 3,
        },
        concealcursor = {
          default = vim.api.nvim_get_option_value('concealcursor', {}),
          rendered = 'nciv',
        },
      },

    })
  end,
}
