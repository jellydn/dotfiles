local M = {}

M.general = {
  n = {
    [";"] = { ":", "command mode", opts = { nowait = true } },
  },
}

-- folding
M.folding = {
  n = {
    ["<leader>d"] = { "<cmd>FoldingEnabled<CR>" },
  },
}

-- outline
M.aerial = {
  n = {
    ["<leader>a"] = { "<cmd>AerialToggle!<CR>" },
    ["<leader>fi"] = { "<cmd>Telescope aerial<CR>" },
  },
}

-- lsp saga
M.lspsaga = {
  n = {
    -- Lsp finder find the symbol definition implement reference
    ["<leader>fd"] = { "<cmd>Lspsaga lsp_finder<CR>" },
    -- Code action (fix code)
    ["<leader>fc"] = { "<cmd>Lspsaga code_action<CR>" },
  },
}

-- hop mapping key
M.hop = {
  n = {
    ["f"] = {
      function()
        require("hop").hint_char1 {
          direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        }
      end,
      "hope forward",
      opts = { nowait = true },
    },
    ["F"] = {
      function()
        require("hop").hint_char1 {
          direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        }
      end,
      "hope backwards",
      opts = { nowait = true },
    },
    ["t"] = {
      function()
        require("hop").hint_char1 {
          direction = require("hop.hint").HintDirection.AFTER_CURSOR,
          current_line_only = true,
          hint_offset = -1,
        }
      end,
      "hope target forward",
      opts = { nowait = true },
    },
    ["T"] = {
      function()
        require("hop").hint_char1 {
          direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
          current_line_only = true,
          hint_offset = -1,
        }
      end,
      "hope target backwards",
      opts = { nowait = true },
    },
    ["<leader>w"] = {
      function()
        require("hop").hint_words()
      end,
      "hope words",
      opts = { nowait = true },
    },
  },
}

return M
