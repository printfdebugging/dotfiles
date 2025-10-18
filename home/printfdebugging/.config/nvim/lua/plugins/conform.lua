return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "isort", "black" },
      },
      -- format_on_save = {
      -- 	lsp_format = "fallback",
      -- 	timeout_ms = 500,
      -- },
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        local current_file_path = vim.fn.expand("%:p")
        local excluded_strings = {
          "online",
          "core",
        }
        for _, str in ipairs(excluded_strings) do
          if string.match(current_file_path, str) then
            return
          end
        end
        require("conform").format({ bufnr = args.buf })
      end,
    })
  end,
}
