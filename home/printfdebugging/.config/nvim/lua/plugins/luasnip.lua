return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
    local ls = require("luasnip")

    local s = ls.snippet
    local i = ls.insert_node
    local f = ls.function_node
    local fmt = require("luasnip.extras.fmt").fmt

    ls.add_snippets("help", {
      s(
        "heading",
        fmt(
          [[
----------------------------------------------------------------------
*<>*
          ]],
          {
            i(1, "heading"),
          },
          { delimiters = "<>" }
        )
      ),

      s(
        "title",
        fmt("*<>*", {
          f(function(_, snip)
            return vim.fn.expand("%:t")
          end, {}),
        }, {
          delimiters = "<>",
        })
      ),

      s(
        "codeblock",
        fmt(
          [[
>{}
    {}
<
				    ]],
          {
            i(1),
            i(2),
          },
          {
            delimiters = "{}",
          }
        )
      ),
    })
  end,
}
