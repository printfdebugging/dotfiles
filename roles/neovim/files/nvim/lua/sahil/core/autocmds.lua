vim.cmd([[
  augroup NoCursorLine
  autocmd!
  autocmd FileType toggleterm setlocal nocursorline nonumber norelativenumber
  autocmd FileType cmake_tools_terminal setlocal nocursorline nonumber norelativenumber
  augroup END
]])

-- Set autoread
vim.cmd("set autoread")
vim.cmd("set laststatus=3")

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

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "help", "man" },
    command = "wincmd L",
})
