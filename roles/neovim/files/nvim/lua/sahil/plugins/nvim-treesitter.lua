return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            auto_install = true, -- don't automatically install the parsers
            ensure_installed = {
                "c",
                "cpp",
                "markdown",
                "markdown_inline",
                "diff",
                "lua",
                "vim",
                "vimdoc",
                "go",
                "python",
                "java",
                "bash",
                "html",
                "yaml",
                "ini",
                "toml",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = false },
        })
    end
}
