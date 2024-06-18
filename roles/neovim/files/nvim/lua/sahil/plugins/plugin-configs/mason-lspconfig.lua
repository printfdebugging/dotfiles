require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"ansiblels",
		"rust_analyzer",
		"clangd",
		"gopls",
		"tsserver",
		"marksman",
		"bashls",
		"cssls",
		"emmet_ls",
	},
})

require("mason-null-ls").setup({
	ensure_installed = {
		"prettier", -- ts/js formatter
		"gofmt",
		"stylua", -- lua formatter
		"eslint_d", -- ts/js linter
		-- "mypy",
		"ruff",
		"black",
		"clang-format",
		"checkmake",
	},
	automatic_installation = true,
})
