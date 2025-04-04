return {
  "neovim/nvim-lspconfig",
  "jose-elias-alvarez/null-ls.nvim",
  "MunifTanjim/prettier.nvim",
  config = function()
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    null_ls.setup({
      sources = {
        -- formatting.prettier.with({ disabled_filetypes = { "cpp", "c" } }), -- (see null-ls docs)
        -- formatting.prettier,
        formatting.stylua,
        formatting.black,
        formatting.gofmt,
        formatting.clang_format,
        diagnostics.mypy,
        diagnostics.ruff,
        diagnostics.eslint_d.with({ -- js/ts linter

          condition = function(utils)
            return utils.root_has_file(".eslintrc.js") -- change file extension if you use something else
          end,
        }),
      },
      -- configure format on save
      on_attach = function(current_client, bufnr)
        if current_client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              local included_filetypes = { "python", "lua", "go" }
              local filetype = vim.bo.filetype
              if vim.tbl_contains(included_filetypes, filetype) then
                vim.lsp.buf.format({
                  filter = function(client)
                    --  only use null-ls for formatting instead of lsp server
                    return client.name == "null-ls"
                  end,
                  bufnr = bufnr,
                })
              end
            end,
          })
        end
      end,
    })
  end,
}
