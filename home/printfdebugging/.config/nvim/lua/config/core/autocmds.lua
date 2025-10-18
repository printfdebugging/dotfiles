----------------------------------------------------------------------
-- MIT License
-- Copyright (c) 2025 Sahil Gautam <printfdebugging@gmail.com>
-- See LICENSE file in the project root for
----------------------------------------------------------------------

vim.cmd([[
  augroup NoCursorLine
  autocmd!
  autocmd FileType toggleterm setlocal nocursorline nonumber norelativenumber
  autocmd FileType cmake_tools_terminal setlocal nocursorline nonumber norelativenumber
  augroup END
]])

vim.cmd([[
  :set autoread
  :set laststatus=3
]])

local markdown_no_warnings = vim.api.nvim_create_augroup("CppFormatingWithClangd", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  group = markdown_no_warnings,
  callback = function(args)
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = args.buf,
      group = markdown_no_warnings,
      callback = function()
        vim.diagnostic.config({ virtual_text = false })
      end,
    })
  end,
})

vim.api.nvim_create_user_command("Help", function(opts)
  vim.cmd("tab help " .. opts.args)
end, { nargs = "*" })
