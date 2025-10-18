return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local actions = require("telescope.actions")
    require("telescope").setup({
      defaults = {
        mappings = {
          n = { ["<C-q>"] = actions.send_to_loclist + actions.open_loclist },
          i = { ["<C-q>"] = actions.send_to_loclist + actions.open_loclist },
        },
        layout_strategy = "vertical",
        layout_config = {
          bottom_pane = {
            height = 20,
            preview_cutoff = 0.5,
            prompt_position = "top",
          },
          center = {
            height = 0.4,
            preview_cutoff = 0.5,
            prompt_position = "top",
            width = 0.9,
          },
          cursor = {
            height = 0.9,
            preview_cutoff = 0.5,
            width = 0.8,
          },
          horizontal = {
            height = 0.9,
            preview_cutoff = 0.5,
            preview_width = 0.6,
            prompt_position = "bottom",
            width = 0.9,
          },
          vertical = {
            height = 200,
            width = 0.9,
            preview_cutoff = 20,
            prompt_position = "bottom",
            -- width = 0.8,
          },
        },
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    })
  end,
}
