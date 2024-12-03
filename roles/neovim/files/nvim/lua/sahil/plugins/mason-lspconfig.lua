return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
		"jay-babu/mason-null-ls.nvim",
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"clangd",
				"gopls",
        "ts_ls",
        "ansiblels",
				"marksman",
				"bashls",
				"cssls",
				"emmet_ls",
			},
			-- handlers = {
			-- 	-- this solves the issue that I faced while working on SFML i.e.
			-- 	-- neovim including headers which are not required
			-- },
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
	end,
}
