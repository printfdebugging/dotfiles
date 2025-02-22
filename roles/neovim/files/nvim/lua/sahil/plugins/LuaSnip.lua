return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
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
      ---
      title: {}
      date: {}
      draft: true
      ---
      ]],
      { i(1), i(0) }
      )
      ),

      s(
      "info",
      fmt(
      [[
      <!-- ok, warning, error, info -->
      {{% note(type="{}", display="block", markdown=true) %}}
      {}
      {{% end %}}
      ]],
      { i(1), i(2)}
      )
      ),
      -- the sequence starts from 1 - 2 - then last 0
    })
  end,
}
