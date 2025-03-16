return {
  "NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"nvim-telescope/telescope.nvim",
	},
  config = function()
    require("neogit").setup({
      highlight = { italic = false, bold = false, underline = false, },
      signs = { hunk = { "", "" }, item = { " ", " " }, section = { " ", " " }, },
      commit_editor = { kind = "tab", show_staged_diff = true, staged_diff_split_kind = "split", spell_check = true, },
      commit_select_view = { kind = "split", },
      commit_view = { kind = "split", verify_commit = vim.fn.executable("gpg") == 1, },
      log_view = { kind = "split", },
      rebase_editor = { kind = "split", },
      reflog_view = { kind = "split", },
      merge_editor = { kind = "split", },
      description_editor = { kind = "split", },
      tag_editor = { kind = "split", },
      preview_buffer = { kind = "split", },
      popup = { kind = "split", },
      stash = { kind = "split", },
      refs_view = { kind = "split", },
    })
  end,
}
