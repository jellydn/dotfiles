local create_cmd = vim.api.nvim_create_user_command
local autocmd = vim.api.nvim_create_autocmd

create_cmd("FoldingEnabled", function()
  -- set fold method --
  vim.o.foldmethod = "expr"
  vim.o.foldexpr = "nvim_treesitter#foldexpr()" -- with presence of treesitter
end, {})


-- Open a file from its last left off position
autocmd("BufReadPost", {
  callback = function()
    if not vim.fn.expand("%:p"):match ".git" and vim.fn.line "'\"" > 1 and vim.fn.line "'\"" <= vim.fn.line "$" then
      vim.cmd "normal! g'\""
      vim.cmd "normal zz"
    end
  end,
})

