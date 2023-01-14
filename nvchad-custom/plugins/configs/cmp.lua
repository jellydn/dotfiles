local M = {}

M.cmp = function()
  local present, cmp = pcall(require, "cmp")
  local options = {
    formatting = {
      format = function(entry, vim_item)
        if entry.source.name == "cmp_tabnine" and entry.completion_item.data ~= nil then
          vim_item.kind = string.format("%s %s", "", " TabNine")
        else
          local icons = require("nvchad_ui.icons").lspkind
          vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
        end

        return vim_item
      end,
    },
    sources = {
      -- TODO: add copilot if needed
      -- { name = "copilot" },
      { name = "cmp_tabnine" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "path" },
    },
  }
  cmp.setup(options)
  -- return options
end

return M
