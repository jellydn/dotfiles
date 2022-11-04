local create_cmd = vim.api.nvim_create_user_command

create_cmd("FoldingEnabled", function()
  -- set fold method --
  vim.o.foldmethod = "expr"
  vim.o.foldexpr = "nvim_treesitter#foldexpr()" -- with presence of treesitter
end, {})

