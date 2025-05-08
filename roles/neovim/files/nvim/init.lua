require("sahil.lazy")

local options = {
  relativenumber = false,
  number = false,
  ruler = false,
  cmdheight = 0,
  background = "dark",
  fillchars = "fold: ",
  tabstop = 4,
  shiftwidth = 4,
  expandtab = true,
  autoindent = true,
  syntax = "off",
  wrap = false,
  ignorecase = true,
  smartcase = true,
  cursorline = false,
  termguicolors = true,
  signcolumn = "no",
  backspace = "indent,eol,start",
  splitright = true,
  splitbelow = true,
  pumheight = 12,
  conceallevel = 1,
  guicursor = "a:block",
  hlsearch = true,
  incsearch = true,
  scrolloff = 0,
  updatetime = 50,
  scroll = 4,
  showtabline = 0,
  concealcursor = "v",
  list = false,
  listchars = {
    space = "⋅",
    tab = "⋅⋅⋅",
  },
  -- mouse = "",
  formatprg = "par w78",
  fcs = "horiz:─,stlnc:─,stl:─,vert:│"

}
for key, value in pairs(options) do
  vim.opt[key] = value
end

vim.opt.fillchars = { eob = " " }
vim.opt.clipboard:append("unnamedplus")
vim.opt.iskeyword:append("-")
vim.opt.iskeyword:append(".")

local globals = {
  noswapfile = true,
  nobackup = true,
  nowritebackup = true,
  laststatus = 0,
  mapleader = " ",
  editorconfig_max_line_length = 100,
}

for key, value in pairs(globals) do
  vim.g[key] = value
end

-- HELPER FUNCTIONS
local telescope = require("telescope.builtin")
function G_telescope_resume()
	if G_telescope_last == 0 then
		G_telescope_last = 1
		telescope.live_grep()
	else
		telescope.resume()
	end
end

local function custom_tabclose()
	if vim.fn.tabpagenr() == 1 then
		print("You cannot close the first tab!")
	else
		vim.cmd("tabclose")
	end
end


vim.g.mapleader = " "
local keymap = vim.keymap

-- BASIC EDITOR BINDINGS
keymap.set("n", "<leader>w", ":w!<CR>")
keymap.set("n", "<leader>q", ":q!<CR>")
keymap.set("n", "<leader>nh", ":nohlsearch<CR>")
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')
keymap.set("n", "m", ":MaximizerToggle!<CR>")
keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>")
keymap.set("x", "p", '"_dP')
keymap.set("n", "<leader>sv", ":vsplit<CR>")
keymap.set("n", "<leader>sh", ":split<CR>")

-- NVIM-DAP
keymap.set("n", "<F5>", function()
	require("dap").continue()
end)
keymap.set("n", "<F10>", function()
	require("dap").step_over()
end)
keymap.set("n", "<F11>", function()
	require("dap").step_into()
end)
keymap.set("n", "<F12>", function()
	require("dap").step_out()
end)
keymap.set("n", "<Leader>b", function()
	require("dap").toggle_breakpoint()
end)
keymap.set("n", "<Leader>B", function()
	require("dap").set_breakpoint()
end)
keymap.set("n", "<Leader>lp", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end)
keymap.set("n", "<Leader>dr", function()
	require("dap").repl.open()
end)
keymap.set("n", "<Leader>dl", function()
	require("dap").run_last()
end)
keymap.set("n", "<F9>", function()
	require("dapui").close()
end)

-- TELESCOPE KEYBINDINGS
G_telescope_last = 0
vim.keymap.set("n", "<leader>ff", ":lua G_telescope_last=0 require('telescope.builtin').find_files()<CR>")
vim.keymap.set("n", "<leader>fh", ":lua G_telescope_last=0 require('telescope.builtin').help_tags()<CR>")
vim.keymap.set("n", "<leader>fm", ":lua G_telescope_last=0 require('telescope.builtin').man_pages()<CR>")
vim.keymap.set("n", "<leader>gs", ":lua G_telescope_last=1 require('telescope.builtin').git_status()<CR>")
vim.keymap.set( "n", "<leader>fb", ":lua G_telescope_last=0 require('telescope.builtin').current_buffer_fuzzy_find()<CR>")
vim.keymap.set( "n", "<leader>ls", ":Telescope buffers<CR>")
vim.keymap.set("n", "<leader>fs", G_telescope_resume)

-- PERSONAL CONVINIENCE
keymap.set("n", "J", "mzJ`z")
keymap.set("n", "t", ":!make run<CR>")
keymap.set("n", "T", ":!make clean<CR>")

-- TABS RELATED KEYBINDINGS
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "<C-q>", custom_tabclose, { noremap = true, silent = true, nowait = true })

for i = 1, 9 do
	vim.api.nvim_set_keymap("n", "<C-" .. i .. ">", i .. "gt", { noremap = true, silent = true })
end

vim.api.nvim_set_keymap("n", "<C-S-T>", ":tab split<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true }) -- now terminal works!
keymap.set("n", "<leader>tx", ":tabclose<CR>")
keymap.set("n", "<leader>tn", ":tabn<CR>")
keymap.set("n", "<leader>tc", ":tabnew<CR>")
keymap.set("n", "<leader>tp", ":tabp<CR>")
keymap.set("n", "<", ":-tabmove<CR>")
keymap.set("n", ">", ":+tabmove<CR>")

-- AUTOCMDS

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
  set shortmess+=I
]])

-- Set autoread
vim.cmd("set autoread")
vim.cmd("set laststatus=0")

-- hide statusline
vim.cmd([[
  augroup AutoRead
  autocmd!
  autocmd CursorMoved * set laststatus=0
  augroup END
]])

vim.cmd([[
  inoremap { {}<Esc>ha
  inoremap ( ()<Esc>ha
  inoremap [ []<Esc>ha
  inoremap " ""<Esc>ha
  inoremap ' ''<Esc>ha
  inoremap ` ``<Esc>ha
]])
