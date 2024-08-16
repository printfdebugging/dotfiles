require("luasnip.loaders.from_vscode").lazy_load()
local ls = require("luasnip")

local snip = ls.snippet
local text = ls.text_node
-- local node = ls.snippet_node
-- local insert = ls.insert_node
-- local func = ls.function_node
-- local choice = ls.choice_node
-- local dynamicn = ls.dynamic_node

-- local date = function()
-- 	return { os.date("%Y-%m-%d") }
-- end

ls.add_snippets(nil, {
	all = {
		snip({
			trig = "info",
			namr = "Metadata",
			dscr = "Yaml metadata format for markdown",
		}, {
			text({
				'<a href="https://sahilgautam.in" ><img align="left" alt="Git" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/domain.png" /> </a>',
				'<a href="https://twitter.com/mesahilgautam" ><img align="left" alt="Twitter" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/twitter-circled.png" /> </a>',
				'<a href="https://www.linkedin.com/in/mesahilgautam" ><img align="left" alt="linkedin" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/linkedin.png" /> </a>',
				'<a href="https://github.com/mesahilgautam" ><img align="left" alt="github" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/github.png" /> </a>',
				'<a href="https://gerrit.libreoffice.org/q/owner:sahil%2540libreoffice.org" ><img align="left" alt="patches" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/add-link.png" /> </a>',
				'<a href="mailto:sahil@libreoffice.org" ><img align="left" alt="mail" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/mail.png" /> </a>',
				'<a href="/index.xml" ><img align="left" alt="rss" width="27px" style="padding-right:00px;" src="https://img.icons8.com/fluency/94/rss.png" /> </a>',
				"<br>",
			}),
		}),
	},
})
