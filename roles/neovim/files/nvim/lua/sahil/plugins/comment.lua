return {
	"numToStr/Comment.nvim",
	lazy = false,
	config = function()
		require("Comment").setup({
			opleader = {
				line = "gc",
				block = "gb",
			},
		})
	end,
}
