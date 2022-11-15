local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {

  -- spell check
  -- b.diagnostics.cspell, b.code_actions.cspell,
  b.completion.spell,
  b.diagnostics.codespell,

  -- webdev stuff
  b.formatting.deno_fmt,
  b.formatting.prettier.with {
    filetypes = { "html", "markdown", "css" },
  },

  -- Lua
  b.formatting.stylua,

  -- Shell
  b.formatting.shfmt,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },

  -- rust
  b.formatting.rustfmt.with {
    extra_args = { "--edition", "2018" },
  },

  -- go
  b.formatting.gofmt,
}

null_ls.setup {
  debug = true,
  on_attach = function()
    vim.api.nvim_create_autocmd("BufWritePost", {
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end,
  sources = sources,
}
