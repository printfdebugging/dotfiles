require("luasnip.loaders.from_vscode").lazy_load()
local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("markdown", {
	s(
		"meta",
		fmt(
			[[
        +++
        title = "{}"
        date = {}
        draft = true
        [taxonomies]
        tags = ["{}"]
        +++
        ]],
			{ i(1), i(2), i(0) }
		)
	),
	-- the sequence starts from 1 - 2 - then last 0
})
