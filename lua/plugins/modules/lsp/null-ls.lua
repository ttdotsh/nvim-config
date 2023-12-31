return {
  'jose-elias-alvarez/null-ls.nvim', -- configure formatters & linters
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local null_ls = require 'null-ls'
    local null_ls_utils = require 'null-ls.utils'

    -- for conciseness
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters

    -- to setup format on save
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    -- configure null_ls
    null_ls.setup {
      root_dir = null_ls_utils.root_pattern('Cargo.toml', 'go.mod', 'package.json', 'pyproject.toml', '.null-ls-root', 'Makefile', '.git'),

      -- setup formatters & linters
      sources = {
        formatting.prettierd.with { -- js/ts formatter
          extra_filetypes = { 'astro' },
        },
        diagnostics.eslint_d.with { -- js/ts linter
          condition = function(utils)
            -- only enable if root has .eslintrc.js or .eslintrc.cjs
            return utils.root_has_file { '.eslintrc.js', '.eslintrc.cjs' }
          end,
        },

        -- formatting.djhtml, -- html jinja template formatter

        formatting.black, -- python formatter
        diagnostics.ruff, -- python linter

        formatting.stylua, -- lua formatter
      },

      -- configure format on save
      on_attach = function(current_client, bufnr)
        if current_client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format {
                filter = function(client)
                  --  only use null-ls for formatting instead of lsp server
                  return client.name == 'null-ls'
                end,
                bufnr = bufnr,
              }
            end,
          })
        end
      end,
    }
  end,
}
