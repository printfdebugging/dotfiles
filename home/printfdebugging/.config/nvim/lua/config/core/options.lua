
-----------------------------------------------------------------------
-- MIT License
-- Copyright (c) 2025 Sahil Gautam <printfdebugging@gmail.com>
-- See LICENSE file in the project root for
----------------------------------------------------------------------

local options = {
  relativenumber = true,
  number = true,
  fixendofline = false,
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
  scrolloff = 5,
  updatetime = 50,
  scroll = 4,
  showtabline = 2,
  concealcursor = "ncv",
  formatprg = "par w70",
  splitkeep = "screen",
  equalalways = true,
  list = true,
  listchars = "tab:⋅⋅⋅,space:⋅,trail:·",
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

