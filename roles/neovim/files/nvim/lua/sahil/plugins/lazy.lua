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
				indent = { char = "│" },
				exclude = { filetypes = { "norg" } },
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
		dir = "/home/printfdebugging/repos/myplugin", -- if at all
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
	{
		"nvim-treesitter/playground",
	},
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},

	{
		"3rd/image.nvim",
		config = function()
			require("image").setup({
				backend = "kitty",
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
					},
					neorg = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "norg" },
					},
					html = {
						enabled = false,
					},
					css = {
						enabled = false,
					},
				},
				max_width = 122,
				max_height = nil,
				max_width_window_percentage = nil,
				max_height_window_percentage = 50,
				window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
				editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
			})
		end,
	},

	-- {
	-- 	"nvim-neorg/neorg",
	-- 	lazy = false,
	-- 	version = "*",
	-- 	config = function()
	-- 		require("neorg").setup({
	-- 			load = {
	-- 				["core.defaults"] = {},
	-- 				["core.export"] = {},
	-- 				["core.concealer"] = {
	-- 					config = {
	-- 						icons = {
	-- 							code_block = {
	-- 								content_only = false, -- Highlight the whole code block, not just content.
	-- 								width = "content",
	-- 								min_width = 122,
	-- 							},
	-- 						},
	-- 					},
	-- 				},
	-- 				["core.dirman"] = {
	-- 					config = {
	-- 						workspaces = {
	-- 							notes = "~/repos/website/notes",
	-- 						},
	-- 						default_workspace = "notes",
	-- 					},
	-- 				},
	-- 			},
	-- 		})
	--
	-- 		vim.wo.foldlevel = 99
	-- 		vim.wo.conceallevel = 2
	-- 	end,
	-- },

	{
		"jubnzv/mdeval.nvim",
		config = function()
			require("mdeval").setup({
				-- Don't ask before executing code blocks
				require_confirmation = false,
				-- Change code blocks evaluation options.
				eval_options = {
					-- Set custom configuration for C++
					cpp = {
						command = { "clang++", "-std=c++20", "-O0" },
						default_header = [[
    #include <iostream>
    #include <vector>
    using namespace std;
      ]],
					},
					python = {
						command = { "python" },
					},

					bash = {
						command = { "sh" },
					},
					-- Add new configuration for Racket
					racket = {
						command = { "racket" }, -- Command to run interpreter
						language_code = "racket", -- Markdown language code
						exec_type = "interpreted", -- compiled or interpreted
						extension = "rkt", -- File extension for temporary files
					},
				},
			})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		}, -- if you use the mini.nvim suite
		config = function()
			require("render-markdown").setup({
				heading = {
					-- Turn on / off heading icon & background rendering
					enabled = true,
					-- Turn on / off any sign column related rendering
					sign = true,
					-- Determines how the icon fills the available space:
					--  inline:  underlying '#'s are concealed resulting in a left aligned icon
					--  overlay: result is left padded with spaces to hide any additional '#'
					position = "overlay",
					-- Replaces '#+' of 'atx_h._marker'
					-- The number of '#' in the heading determines the 'level'
					-- The 'level' is used to index into the array using a cycle
					icons = { "◉ ", "○ ", "✸ ", "✿ ", "󰲩 ", "󰲫 " },
					-- Added to the sign column if enabled
					-- The 'level' is used to index into the array using a cycle
					signs = { "" },
					-- Width of the heading background:
					--  block: width of the heading text
					--  full:  full width of the window
					-- Can also be an array of the above values in which case the 'level' is used
					-- to index into the array using a clamp
					width = "block",
					-- Amount of padding to add to the left of headings
					left_pad = 0,
					-- Amount of padding to add to the right of headings when width is 'block'
					right_pad = 0,
					-- Minimum width to use for headings when width is 'block'
					min_width = 0,
					-- Determins if a border is added above and below headings
					border = false,
					-- Highlight the start of the border using the foreground highlight
					border_prefix = false,
					-- Used above heading for border
					above = "▄",
					-- Used below heading for border
					below = "▀",
					-- The 'level' is used to index into the array using a clamp
					-- Highlight for the heading icon and extends through the entire line
					backgrounds = {
						"RenderMarkdownH1Bg",
						"RenderMarkdownH2Bg",
						"RenderMarkdownH3Bg",
						"RenderMarkdownH4Bg",
						"RenderMarkdownH5Bg",
						"RenderMarkdownH6Bg",
					},
					-- The 'level' is used to index into the array using a clamp
					-- Highlight for the heading and sign icons
					foregrounds = {
						"RenderMarkdownH1",
						"RenderMarkdownH2",
						"RenderMarkdownH3",
						"RenderMarkdownH4",
						"RenderMarkdownH5",
						"RenderMarkdownH6",
					},
				},

				code = {
					-- Turn on / off code block & inline code rendering
					enabled = true,
					-- Turn on / off any sign column related rendering
					sign = false,
					-- Determines how code blocks & inline code are rendered:
					--  none:     disables all rendering
					--  normal:   adds highlight group to code blocks & inline code, adds padding to code blocks
					--  language: adds language icon to sign column if enabled and icon + name above code blocks
					--  full:     normal + language
					style = "full",
					-- Determines where language icon is rendered:
					--  right: right side of code block
					--  left:  left side of code block
					position = "right",
					-- An array of language names for which background highlighting will be disabled
					-- Likely because that language has background highlights itself
					disable_background = {},
					-- Width of the code block background:
					--  block: width of the code block
					--  full:  full width of the window
					width = "block",
					-- Amount of padding to add to the left of code blocks
					left_pad = 2,
					-- Amount of padding to add to the right of code blocks when width is 'block'
					right_pad = 0,
					-- Minimum width to use for code blocks when width is 'block'
					min_width = 122,
					-- Determins how the top / bottom of code block are rendered:
					--  thick: use the same highlight as the code body
					--  thin:  when lines are empty overlay the above & below icons
					border = "thick",
					-- Used above code blocks for thin border
					above = "▄",
					-- Used below code blocks for thin border
					below = "▀",
					-- Highlight for code blocks
					highlight = "RenderMarkdownCode",
					-- Highlight for inline code
					highlight_inline = "RenderMarkdownCodeInline",
				},

				bullet = {
					-- Turn on / off list bullet rendering
					enabled = true,
					-- Replaces '-'|'+'|'*' of 'list_item'
					-- How deeply nested the list is determines the 'level'
					-- The 'level' is used to index into the array using a cycle
					-- If the item is a 'checkbox' a conceal is used to hide the bullet instead
					icons = { "●", "○", "◆", "◇" },
					-- Padding to add to the left of bullet point
					left_pad = 0,
					-- Padding to add to the right of bullet point
					right_pad = 0,
					-- Highlight for the bullet icon
					highlight = "RenderMarkdownBullet",
				},

				checkbox = {
					-- Turn on / off checkbox state rendering
					enabled = true,
					unchecked = {
						-- Replaces '[ ]' of 'task_list_marker_unchecked'
						icon = " 󰄱 ",
						-- Highlight for the unchecked icon
						highlight = "RenderMarkdownUnchecked",
					},
					checked = {
						-- Replaces '[x]' of 'task_list_marker_checked'
						icon = " 󰱒 ",
						-- Highligh for the checked icon
						highlight = "RenderMarkdownChecked",
					},
					-- Define custom checkbox states, more involved as they are not part of the markdown grammar
					-- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
					-- Can specify as many additional states as you like following the 'todo' pattern below
					--   The key in this case 'todo' is for healthcheck and to allow users to change its values
					--   'raw':       Matched against the raw text of a 'shortcut_link'
					--   'rendered':  Replaces the 'raw' value when rendering
					--   'highlight': Highlight for the 'rendered' icon
					custom = {
						todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
					},
				},

				quote = {
					-- Turn on / off block quote & callout rendering
					enabled = true,
					-- Replaces '>' of 'block_quote'
					icon = "▋",
					-- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text if
					-- not configured correctly with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'. A
					-- combination of these that is likely to work is showbreak = '  ' (2 spaces), breakindent = true,
					-- breakindentopt = '' (empty string). These values are not validated by this plugin. If you want
					-- to avoid adding these to your main configuration then set them in win_options for this plugin.
					repeat_linebreak = false,
					-- Highlight for the quote icon
					highlight = "RenderMarkdownQuote",
				},

				pipe_table = {
					-- Turn on / off pipe table rendering
					enabled = true,
					-- Pre configured settings largely for setting table border easier
					--  heavy:  use thicker border characters
					--  double: use double line border characters
					--  round:  use round border corners
					--  none:   does nothing
					preset = "none",
					-- Determines how the table as a whole is rendered:
					--  none:   disables all rendering
					--  normal: applies the 'cell' style rendering to each row of the table
					--  full:   normal + a top & bottom line that fill out the table when lengths match
					style = "full",
					-- Determines how individual cells of a table are rendered:
					--  overlay: writes completely over the table, removing conceal behavior and highlights
					--  raw:     replaces only the '|' characters in each row, leaving the cells unmodified
					--  padded:  raw + cells are padded with inline extmarks to make up for any concealed text
					cell = "padded",
					-- Gets placed in delimiter row for each column, position is based on alignmnet
					alignment_indicator = "━",
        -- Characters used to replace table border
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
        -- stylua: ignore
        border = {
            '┌', '┬', '┐',
            '├', '┼', '┤',
            '└', '┴', '┘',
            '│', '─',
        },
					-- Highlight for table heading, delimiter, and the line above
					head = "RenderMarkdownTableHead",
					-- Highlight for everything else, main table rows and the line below
					row = "RenderMarkdownTableRow",
					-- Highlight for inline padding used to add back concealed space
					filler = "RenderMarkdownTableFill",
				},

				callout = {
					note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
					tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
					important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
					warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
					caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
					-- Obsidian: https://help.a.md/Editing+and+formatting/Callouts
					abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
					todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
					success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
					question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
					failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "RenderMarkdownError" },
					danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
					bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
					example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
					quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote" },
				},

				link = {
					-- Turn on / off inline link icon rendering
					enabled = true,
					-- Inlined with 'image' elements
					image = "󰥶 ",
					-- Fallback icon for 'inline_link' elements
					hyperlink = "󰌹 ",
					-- Applies to the fallback inlined icon
					highlight = "RenderMarkdownLink",
					-- Define custom destination patterns so icons can quickly inform you of what a link
					-- contains. Applies to 'inline_link' and wikilink nodes.
					-- Can specify as many additional values as you like following the 'web' pattern below
					--   The key in this case 'web' is for healthcheck and to allow users to change its values
					--   'pattern':   Matched against the destination text see :h lua-pattern
					--   'icon':      Gets inlined before the link text
					--   'highlight': Highlight for the 'icon'
					custom = {
						web = { pattern = "^http[s]?://", icon = "󰖟 ", highlight = "RenderMarkdownLink" },
					},
				},
				win_options = {
					-- See :h 'conceallevel'
					conceallevel = {
						-- Used when not being rendered, get user setting
						default = vim.api.nvim_get_option_value("conceallevel", {}),
						-- Used when being rendered, concealed text is completely hidden
						rendered = 3,
					},
					-- See :h 'concealcursor'
					concealcursor = {
						-- Used when not being rendered, get user setting
						default = vim.api.nvim_get_option_value("concealcursor", {}),
						-- Used when being rendered, disable concealing text in all modes
						rendered = "i",
					},
				},
			})
		end,
	},
})
