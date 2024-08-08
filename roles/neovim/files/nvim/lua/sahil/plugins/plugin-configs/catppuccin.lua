-- this is a comment
require("catppuccin").setup({
	flavour = "mocha",
	background = {
		light = "latte",
		dark = "mocha",
	},
	transparent_background = true,
	show_end_of_buffer = false,
	term_colors = true,
	dim_inactive = {
		enabled = false,
		shade = "dark",
		percentage = 0.15,
	},
	no_italic = false,
	no_bold = false,
	no_underline = false,
	styles = {
		comments = { "italic" },
		conditionals = {},
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
		misc = {},
	},
	color_overrides = {
		all = {},
		mocha = {
			rosewater = "#f5e0dc",
			flamingo = "#f2cdcd",
			pink = "#f5c2e7",
			mauve = "#cba6f7",
			red = "#f38ba8",
			maroon = "#eba0ac",
			peach = "#fab387",
			yellow = "#ECBE7B",
			green = "#98be65",
			teal = "#4db5bd",
			sky = "#89dceb",
			sapphire = "#74c7ec",
			blue = "#51afef",
			lavender = "#b4befe",
			text = "#EEFFFF",
			subtext1 = "#bac2de",
			subtext0 = "#a6adc8",
			overlay2 = "#9399b2",
			overlay1 = "#7f849c",
			overlay0 = "#5B6268",
			surface2 = "#676E95",
			surface1 = "#6C7085",
			surface0 = "#2D3952",
			-- base = "#676E95",
			-- mantle = "#181825",
			-- crust = "#11111b",
		},
		frappe = {},
		macchiato = {},
		latte = {},
	},
	highlight_overrides = {
		mocha = function(mocha)
			return {
				-- ["@keyword.directive"] = { fg = "#C586C0" },
				-- ["@keyword.import"] = { fg = "#C586C0" },
				-- ["@function.method"] = { fg = mocha.blue },
				-- ["@function.cpp"] = { fg = mocha.blue },
				-- ["@function.call"] = { fg = mocha.blue },
				-- ["@function.method.call"] = { fg = mocha.blue },
				-- ["@constructor"] = { fg = mocha.blue },
				-- ["@constant"] = { fg = mocha.peach },
				-- ["@operator"] = { fg = mocha.blue },
				-- ["@keyword.type"] = { fg = mocha.blue },
				-- ["@comment"] = { fg = "#6A9955" },
				-- ["@string"] = { fg = "#CE9178" },

				-- Neorg custom highlighting
				["@neorg.headings.1.title"] = { fg = "#51afef", style = { "bold" } },
				["@neorg.headings.1.prefix"] = { fg = "#51afef", style = { "bold" } },
				["@neorg.headings.2.title"] = { fg = "#A9A1E1", style = { "bold" } },
				["@neorg.headings.2.prefix"] = { fg = "#A9A1E1", style = { "bold" } },
				["@neorg.headings.3.title"] = { fg = "#A9A1E1", style = { "bold" } },
				["@neorg.headings.3.prefix"] = { fg = "#A9A1E1", style = { "bold" } },
				["@neorg.tags.ranged_verbatim.code_block"] = { bg = "#23272e" },
				["@neorg.links.file"] = { fg = "#51afef", style = { "bold", "underline" } },

				["@neorg.tags.ranged_verbatim.parameters"] = { fg = "#23272e" },
				["@neorg.tags.ranged_verbatim.parameters.word"] = { fg = "#23272e" },
				["@neorg.tags.ranged_verbatim.begin"] = { fg = "#23272e" },
				["@neorg.tags.ranged_verbatim.end"] = { fg = "#23272e" },
				["@neorg.tags.ranged_verbatim.name"] = { fg = "#23272e" },
				["@neorg.tags.ranged_verbatim.name.word"] = { fg = "#23272e" },

				--
				["@markup.heading.1.markdown"] = { fg = mocha.blue, style = { "bold" } },
				["@markup.heading.2.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
				["@markup.heading.3.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
				["@markup.heading.4.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
				["@markup.heading.5.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
				["@markup.heading.6.markdown"] = { fg = "#A9A1E1", style = { "bold" } },
				["@markup.link.label"] = { fg = mocha.blue, style = { "bold", "underline" } },
			}
		end,
	},
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		treesitter = true,
		notify = false,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
	},
})

vim.cmd.colorscheme("catppuccin")

vim.cmd([[
    highlight TabLineSel    guifg=#ffffff
    highlight LineNr        guifg=#bbc2cf 
    highlight LineNrAbove   guifg=#3f444a
    highlight LineNrBelow   guifg=#3f444a
    highlight CursorLine    guibg=#21242b
    highlight CursorLineNr  guibg=#21242b
]])

vim.cmd([[highlight! link CursorLineSign CursorLine]])
