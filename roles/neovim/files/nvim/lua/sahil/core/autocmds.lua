-- Set tabstop to 2 for Lua files
vim.cmd([[
  augroup LuaTabStop
  autocmd!
  autocmd FileType lua setlocal tabstop=2
  autocmd FileType lua setlocal shiftwidth=2
  augroup END
]])

vim.cmd([[
  augroup LuaTabStop
  autocmd!
  autocmd FileType javascript setlocal tabstop=2
  autocmd FileType javascript setlocal shiftwidth=2
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

-- format all the c/cpp files with clang-format except for the files
-- which have "/home/printf/repos/libreoffice/" in the path
local cpp_formating_group = vim.api.nvim_create_augroup("CppFormatingWithClangd", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	group = cpp_formating_group,
	callback = function(args)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = args.buf,
			group = cpp_formating_group,
			callback = function()
				if not string.find(vim.fn.expand("%:p"), "/home/printf/repos/libreoffice/") then
					vim.lsp.buf.format({ async = false, bufnr = args.buf })
				end
			end,
		})
	end,
})

-- " Define an autocommand group to avoid duplication
vim.cmd([[
  augroup MatchParenHighlight
    autocmd!
    autocmd BufEnter * hi MatchParen guifg=NONE guibg=NONE
  augroup END
]])

-- Function to open a terminal in the first tab
local function open_terminal_in_first_tab()
	if vim.fn.tabpagenr("$") == 1 and vim.bo.filetype ~= "terminal" then
		vim.cmd("term")
		vim.cmd("setlocal nonumber")
		vim.cmd("setlocal norelativenumber")
	end

	if vim.fn.argc() > 0 then
		for i = 0, vim.fn.argc() - 1 do
			vim.cmd("tabnew " .. vim.fn.argv(i))
		end
	else
		vim.cmd("tabnew")
	end
	-- handle the case where if argv is not empty, then
	-- we open those different files in different tabs starting
	-- at 2
end

-- Set up an autocmd to ensure the first tab is always a terminal
vim.api.nvim_create_autocmd("VimEnter", {
	callback = open_terminal_in_first_tab,
})
vim.cmd([[
  augroup Terminal
    autocmd!
    autocmd TermOpen "terminal" setlocal nonumber norelativenumber
  augroup END
]])
