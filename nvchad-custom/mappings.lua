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

-- NOTE: Install https://github.com/fedepujol/move.nvim if needed
-- moving
M.moving = {
  n = {
    ["<A-Down>"] = { ":m .+1<CR>", "move line down" },
    ["<A-Up>"] = { ":m .-2<CR>", "move line up" },
  },
}

-- Mac OSX
M.macosx = {
  n = {
    -- save
    ["<leader>s"] = { "<cmd> w <CR>", "save file" },
  },
}

-- spell check, refer https://jdhao.github.io/2019/04/29/nvim_spell_check/
M.spellcheck = {
  n = {
    ["<F10>"] = { "<cmd> set spell! <CR>", "Toggle spell check" },
  },
}

-- override nvterm
M.nvterm = {}

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

    -- -- Diagnsotic jump can use `<c-o>` to jump back
    ["[e"] = { "<cmd>Lspsaga diagnostic_jump_prev<CR>" },
    ["]e"] = { "<cmd>Lspsaga diagnostic_jump_next<CR>" },

    -- Only jump to error
    ["[E"] = {
      function()
        require("lspsaga.diagnostic").goto_prev { severity = vim.diagnostic.severity.ERROR }
      end,
      { silent = true },
    },
    ["]E"] = {
      function()
        require("lspsaga.diagnostic").goto_next { severity = vim.diagnostic.severity.ERROR }
      end,
      { silent = true },
    },
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
