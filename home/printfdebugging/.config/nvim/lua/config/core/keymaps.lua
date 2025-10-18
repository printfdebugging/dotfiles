
----------------------------------------------------------------------
-- MIT License
-- Copyright (c) 2025 Sahil Gautam <printfdebugging@gmail.com>
-- See LICENSE file in the project root for
----------------------------------------------------------------------

local helpers = require("config.core.helpers")


vim.g.mapleader = " "

local normal_mode_leader_keymaps = {
  { "w", ":w!<CR>" },
  { "q", ":q!<CR>" },
  { "e", ":NvimTreeFindFileToggle!<CR>" },
  { "y", ':"+y' },
  { "Y", ':"+Y' },
  { "D", ":Lspsaga show_line_diagnostics<CR>" },
  { "d", ":Lspsaga show_cursor_diagnostics<CR>" },
  { "1", ':lua require("harpoon.ui").nav_file(1)<CR>' },
  { "2", ':lua require("harpoon.ui").nav_file(2)<CR>' },
  { "3", ':lua require("harpoon.ui").nav_file(3)<CR>' },
  { "4", ':lua require("harpoon.ui").nav_file(4)<CR>' },
  { "5", ':lua require("harpoon.ui").nav_file(5)<CR>' },

  { "nh", ":nohlsearch<CR>" },
  { "mp", ":MarkdownPreviewToggle<CR>" },
  { "ca", ":Lspsaga code_action<CR>" },
  { "rn", ":Lspsaga rename<CR>" },
  { "ff", ":lua telescope_last=0 require('telescope.builtin').find_files()<CR>" },
  { "fh", ":lua telescope_last=0 require('telescope.builtin').help_tags()<CR>" },
  { "gs", ":lua telescope_last=1 require('telescope.builtin').git_status()<CR>" },
  { "ls", ":Telescope buffers<CR>" },
  { "fb", ":lua telescope_last=0 require('telescope.builtin').current_buffer_fuzzy_find()<CR>" },
  { "fs", helpers.telescope_resume },
  { "mm", ':lua require("harpoon.mark").add_file()<CR>' },
  { "gt", ":Gitsigns toggle_deleted<CR>" },
  { "gn", ":Gitsigns next_hunk<CR>" },
  { "gp", ":Gitsigns prev_hunk<CR>" },
  { "gx", ":Gitsigns reset_hunk<CR>" },
  { "rr", ":MdEvalClean<CR>" },
  { "sv", ":vsplit<CR>" },
  { "sh", ":split<CR>" },
  { "tx", ":tabclose<CR>" },
  { "tn", ":tabn<CR>" },
  { "tc", ":tabnew<CR>" },
  { "tp", ":tabp<CR>" },
  { "rs", ":LspRestart<CR>" },
  { "oe", ":lua vim.diagnostic.open_float()<CR>" },
  { "gh", ':lua require("neogit").open()<CR>' },
  { "fm", helpers.show_man_page },
  { "oo", helpers.follow_wiki_link },
  { "ol", ":Outline<CR>" },
}

local normal_mode_keymaps = {
  { "<C-a>", helpers.build_project },
  { "<C-s>", helpers.run_project },
  { "<C-d>", helpers.clean_project },
  { "m", ":MaximizerToggle!<CR>" },
  { "m", ":MaximizerToggle!<CR>" },
  { "z", ":ToggleTerm<CR>" },
  { "J", "mzJ`z" },
  { "s", ":source %<CR>" },
  { "<", ":-tabmove<CR>" },
  { ">", ":+tabmove<CR>" },
  { "K", helpers.man_or_hover_doc },
  { "gf", ":Lspsaga lsp_finder<CR>" },
  { "gD", ":Lspsaga peek_definition<CR>" },
  { "gd", ":Lspsaga goto_definition<CR>" },
  { "gi", ":lua vim.lsp.buf.implementation()<CR>" },
  { "[d", ":Lspsaga diagnostic_jump_prev<CR>" },
  { "]d", ":Lspsaga diagnostic_jump_next<CR>" },
  { "gr", ":lua vim.lsp.buf.references()<CR>" },
  { "<C-n>", ":cnext<CR>" },
  { "<C-p>", ":cprev<CR>" },
  { "<M-n>", ":lnext<CR>" },
  { "<M-p>", ":lprev<CR>" },
  { "<C-e>", ':lua require("harpoon.ui").toggle_quick_menu()<CR>' },
  { "<C-t>", ":tabnew<CR>" },
  { "<C-q>", helpers.custom_tabclose },
  { "<C-S-T>", ":tab split<CR>" },
  { "<C-1>", "1gt<CR>" },
  { "<C-2>", "2gt<CR>" },
  { "<C-3>", "3gt<CR>" },
  { "<C-4>", "4gt<CR>" },
  { "<C-5>", "5gt<CR>" },
  { "<C-6>", "6gt<CR>" },
  { "<C-7>", "7gt<CR>" },
}

local keymaps_with_mode = {
  { "x", "p", '"_dP' },
  { "v", "J", ":m '>+1<CR>gv=gv" },
  { "v", "K", ":m '<-2<CR>gv=gv" },
  { "v", "<leader>y", '"+y' },
  {
    { "i", "s" },
    "<M-l>",
    function()
      require("luasnip").jump(1)
    end,
  },
  {
    { "i", "s" },
    "<M-h>",
    function()
      require("luasnip").jump(-1)
    end,
  },
}

for _, map in pairs(normal_mode_leader_keymaps) do
  vim.keymap.set("n", "<leader>" .. map[1], map[2])
end

for _, map in pairs(normal_mode_keymaps) do
  vim.keymap.set("n", map[1], map[2])
end

for _, map in pairs(keymaps_with_mode) do
  vim.keymap.set(map[1], map[2], map[3])
end


