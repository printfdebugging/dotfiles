---@diagnostic disable: undefined-doc-name, assign-type-mismatch
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

require("lazy").setup({
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = true,
	},
	{
		"NTBBloodbath/doom-one.nvim",
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = true,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		commit = "29be0919b91fb59eca9e90690d76014233392bef",
		config = function()
			require("ibl").setup({
				indent = { char = "┆" },
				whitespace = {
					remove_blankline_trail = false,
				},
				scope = { enabled = false },
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {}, -- this is equalent to setup({}) function
	},

	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = false,
	},

	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		-- commit = "73ab665",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = true,
	},

	{
		"christoomey/vim-tmux-navigator",
	},

	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
	},

	{
		"numToStr/Comment.nvim",
		config = true,
		lazy = false,
	},

	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = true,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/nvim-cmp",

			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind.nvim",
			"nvimdev/lspsaga.nvim",
		},
		config = true,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"jay-babu/mason-null-ls.nvim",
		},
		config = true,
	},

	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({ auto_install = true })
		end,
	},

	{
		"jose-elias-alvarez/null-ls.nvim",
	},

	{
		"szw/vim-maximizer",
	},

	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},

	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},

	{
		"jghauser/follow-md-links.nvim",
	},

	{
		"simrat39/rust-tools.nvim",
		config = function()
			require("rust-tools").setup({})
		end,
	},

	{
		"williamboman/mason.nvim",
		"mfussenegger/nvim-dap",
		"jay-babu/mason-nvim-dap.nvim",
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "python", "delve" },
			})
		end,
	},

	{
		"mfussenegger/nvim-dap",
		-- config = true,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = true,
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		config = true,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					section_separators = { left = "|", right = "|" },
					component_separators = { left = "|", right = "|" },
				},
			})
		end,
	},

	-- {
	-- 	name = "neogit",
	-- 	tag = "v0.0.1",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"sindrets/diffview.nvim",
	-- 		"nvim-telescope/telescope.nvim",
	-- 	},
	-- 	dir = "/home/printf/repos/github/neogit",
	-- 	config = function()
	-- 		require("neogit").setup({})
	-- 	end,
	-- },

	{
		"NeogitOrg/neogit",
		tag = "v0.0.1",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = true,
	},

	{
		"neovim/nvim-lspconfig",
		"jose-elias-alvarez/null-ls.nvim",
		"MunifTanjim/prettier.nvim",
		config = true,
	},

	{
		"jbyuki/one-small-step-for-vimkind",
		"mfussenegger/nvim-dap",
	},

	{
		"leoluz/nvim-dap-go",
		config = true,
	},

	{
		name = "myplugin",
		dir = "/home/printf/repos/github/myplugin",
	},
	{
		"alvarosevilla95/luatab.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("luatab").setup({})
		end,
	},
	{
		"epheien/termdbg",
	},
})
