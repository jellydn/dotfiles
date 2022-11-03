local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--

-- set fold method --
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()" -- with presence of treesitter
-- Disable folding at startup.
vim.o.foldenable = "false"
