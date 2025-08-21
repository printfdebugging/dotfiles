local options = {
	relativenumber = false,
	number = true,
	ruler = false,
	cmdheight = 1,
	background = "dark",
	fillchars = "fold: ",
	tabstop = 4,
	shiftwidth = 4,
	expandtab = true,
	autoindent = true,
	syntax = "on",
	wrap = false,
	ignorecase = true,
	smartcase = true,
	cursorline = true,
	termguicolors = true,
	signcolumn = "yes",
	backspace = "indent,eol,start",
	splitright = true,
	splitbelow = true,
	pumheight = 12,
	conceallevel = 0,
	guicursor = "a:block",
	hlsearch = true,
	incsearch = true,
	scrolloff = 0,
	updatetime = 50,
	scroll = 4,
	showtabline = 2,
	concealcursor = "ncv",
	-- mouse = "",
	formatprg = "par w70",
}

local globals = {
	noswapfile = true,
	nobackup = true,
	nowritebackup = true,
	laststatus = 3,
	mapleader = " ",
	editorconfig_max_line_length = 100,
}

vim.opt.fillchars = { eob = " " }
vim.opt.clipboard:append("unnamedplus")

for key, value in pairs(options) do
	vim.opt[key] = value
end

for key, value in pairs(globals) do
	vim.g[key] = value
end
