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

local set_namespace = vim.api.nvim__set_hl_ns or vim.api.nvim_set_hl_ns
local namespace = vim.api.nvim_create_namespace("dap-hlng")
vim.api.nvim_set_hl(namespace, "DapBreakpoint", { fg = "#eaeaeb", bg = "#ffffff" })
vim.api.nvim_set_hl(namespace, "DapLogPoint", { fg = "#eaeaeb", bg = "#ffffff" })
vim.api.nvim_set_hl(namespace, "DapStopped", { fg = "#eaeaeb", bg = "#ffffff" })
vim.fn.sign_define("DapBreakpoint",
  { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint", })
vim.fn.sign_define("DapBreakpointCondition",
  { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointRejected",
  { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })

-- vim.api.nvim_create_augroup("MarkdownKeymap", { clear = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   group = "MarkdownKeymap",
--   pattern = "markdown",
--   command = "setlocal keymap=accents",
-- })

-- vim.g.markdown_folding = 1
-- opt.guicursor =
--   "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
