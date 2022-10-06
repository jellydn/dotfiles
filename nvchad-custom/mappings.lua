local M = {}

M.general = {
  n = {
    [";"] = { ":", "command mode", opts = { nowait = true } },
  },
}

-- more keybinds!
-- toggle float term
M.term = {
  n = {
    ["<leader>t"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "toggle floating term",
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
  },
}

return M
