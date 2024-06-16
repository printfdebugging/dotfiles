require("sahil.core.helpers")

vim.g.mapleader = " "
local keymap = vim.keymap -- for conciseness

-- BASIC EDITOR BINDINGS
keymap.set("n", "<leader>w", ":w!<CR>")
keymap.set("n", "<leader>q", ":q!<CR>")
keymap.set("n", "<leader>nh", ":nohlsearch<CR>")
keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>")
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')
keymap.set("n", "m", ":MaximizerToggle!<CR>")
keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>")
keymap.set("n", "s", ":source %<CR>")
keymap.set("n", "z", ":ToggleTerm<CR>")
keymap.set("x", "p", '"_dP')
keymap.set("n", "<leader>sv", ":vsplit<CR>")
keymap.set("n", "<leader>sh", ":split<CR>")

keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tc", ":tabnew<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>oe", ":lua vim.diagnostic.open_float()<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>oo", ":FeMaco<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>gh", ':lua require("neogit").open()<CR>')

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
-- vim.keymap.set("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<CR>")
vim.keymap.set("n", "<leader>fh", ":lua G_telescope_last=0 require('telescope.builtin').help_tags()<CR>")
vim.keymap.set("n", "<leader>fm", ":lua G_telescope_last=0 require('telescope.builtin').man_pages()<CR>")
vim.keymap.set("n", "<leader>gs", ":lua G_telescope_last=1 require('telescope.builtin').git_status()<CR>")
vim.keymap.set(
	"n",
	"<leader>fb",
	":lua G_telescope_last=0 require('telescope.builtin').current_buffer_fuzzy_find()<CR>"
)
vim.keymap.set("n", "<leader>fs", G_telescope_resume)

-- NVIM-TREE
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>")

-- HARPOON
vim.keymap.set("n", "<leader>mm", ':lua require("harpoon.mark").add_file()<CR>')
vim.keymap.set("n", "<C-e>", ':lua require("harpoon.ui").toggle_quick_menu()<CR>')
vim.keymap.set("n", "<leader>1", ':lua require("harpoon.ui").nav_file(1)<CR>')
vim.keymap.set("n", "<leader>2", ':lua require("harpoon.ui").nav_file(2)<CR>')
vim.keymap.set("n", "<leader>3", ':lua require("harpoon.ui").nav_file(3)<CR>')
vim.keymap.set("n", "<leader>4", ':lua require("harpoon.ui").nav_file(4)<CR>')
vim.keymap.set("n", "<leader>5", ':lua require("harpoon.ui").nav_file(5)<CR>')

-- GITSIGNS
vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_deleted<CR>")
vim.keymap.set("n", "<leader>gn", ":Gitsigns next_hunk<CR>")
vim.keymap.set("n", "<leader>gp", ":Gitsigns prev_hunk<CR>")
vim.keymap.set("n", "<leader>gx", ":Gitsigns reset_hunk<CR>")

-- PERSONAL CONVINIENCE
keymap.set("n", "<leader>x", ":lua ExecuteCurrentFileProgram()<CR>", { noremap = true, silent = true })
keymap.set("n", "J", "mzJ`z")
keymap.set("n", "t", ":!make run<CR>")
-- keymap.set("n", "T", ":!make clean<CR>")
-- keymap.set("n", "S", ":!make save<CR>")
-- keymap.set("n", "\\", ":lua saveToReadmeFile()<CR>") -- mapping to restart lsp if necessary
-- keymap.set("n", "M", ":lua today()<CR>") -- mapping to restart lsp if necessary

-- LUASNIP
vim.keymap.set({ "i", "s" }, "<M-l>", function()
	require("luasnip").jump(1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<M-h>", function()
	require("luasnip").jump(-1)
end, { silent = true })

local function custom_tabclose()
	if vim.fn.tabpagenr() == 1 then
		print("You cannot close the first tab!")
	else
		vim.cmd("tabclose")
	end
end

-- Tabs related keybindings

-- Key mappings
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "<C-q>", "<C-w>", { noremap = true })
vim.keymap.set("n", "<C-w>", custom_tabclose, { noremap = true, silent = true, nowait = true })

for i = 1, 9 do
	vim.api.nvim_set_keymap("n", "<C-" .. i .. ">", i .. "gt", { noremap = true, silent = true })
end

vim.api.nvim_set_keymap("n", "<C-S-T>", ":tab split<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true }) -- now terminal works!
