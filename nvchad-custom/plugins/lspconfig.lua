local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

local servers = { "html", "cssls", "rust_analyzer", "gopls", "tailwindcss", "jsonls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern "package.json",
}

lspconfig.denols.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
}

-- NOTE: enable rome if needed
--
-- lspconfig.rome.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   root_dir = lspconfig.util.root_pattern "rome.json",
-- }
