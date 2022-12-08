local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local function eslint_config_exists()
  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  local current_dir = vim.fn.getcwd()
  local pkg_json = current_dir .. "/package.json"
  if vim.fn.filereadable(pkg_json) == 1 then
    if vim.fn.json_decode(vim.fn.readfile(pkg_json))["eslintConfig"] then
      return true
    end
  end

  return false
end

local sources = {

  -- spell check
  -- b.code_actions.cspell,
  -- b.diagnostics.cspell,
  b.diagnostics.codespell,
  b.diagnostics.misspell,
  b.diagnostics.write_good,
  b.code_actions.proselint,

  -- webdev stuff
  b.diagnostics.eslint_d.with {
    condition = function()
      return eslint_config_exists()
    end,
  },
  b.code_actions.eslint_d,
  b.formatting.eslint_d,
  -- b.formatting.deno_fmt.with({
  --   	filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
  -- }),
  -- TODO: install romejs if possible
  b.formatting.prettierd.with {
    filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
  },

  -- Lua
  b.formatting.stylua,

  -- rust
  b.formatting.rustfmt.with {
    extra_args = { "--edition", "2018" },
  },

  -- go
  b.diagnostics.revive,
  b.formatting.gofmt,

  -- proto buf
  b.diagnostics.protolint,
}

null_ls.setup {
  on_attach = function(client)
    -- format on save
    require("lsp-format").on_attach(client)
  end,
  sources = sources,
}
