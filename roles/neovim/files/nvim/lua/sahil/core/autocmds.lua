-- Set tabstop to 2 for Lua files
vim.cmd([[
  augroup LuaTabStop
  autocmd!
  autocmd FileType lua set tabstop=2
  autocmd FileType lua set shiftwidth=2
  augroup END
]])

vim.cmd([[
  augroup JavaScriptTabStop
  autocmd!
  autocmd FileType javascript set tabstop=2
  autocmd FileType javascript set shiftwidth=2
  augroup END
]])

vim.cmd([[
  augroup JavaScriptTabStop
  autocmd!
  autocmd FileType c set tabstop=2
  autocmd FileType c set shiftwidth=2
  augroup END
]])

-- Set autoread
vim.cmd("set autoread")
vim.cmd("set laststatus=3")

-- Define an autocommand for CursorHold and CursorHoldI events
vim.cmd([[
  augroup AutoRead
  autocmd!
  autocmd CursorHold,CursorHoldI * checktime
  augroup END
]])

-- " define an autocommand group to avoid duplication
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	command = "setlocal nonumber norelativenumber",
})

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
