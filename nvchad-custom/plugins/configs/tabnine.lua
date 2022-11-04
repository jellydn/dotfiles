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
      { name = "cmp_tabnine" },
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "path" },
    },
  }
  cmp.setup(options)
  -- return options
end

M.tabnine = function()
  local present, tabnine = pcall(require, "cmp_tabnine.config")
  local config = {
    max_lines = 1000,
    max_num_results = 5,
    sort = true,
    run_on_every_keystroke = true,
    show_prediction_strength = false,
  }
  tabnine.setup(config)
  -- return config
end

return M
