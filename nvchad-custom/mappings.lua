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
        require("hop").hint_char1()
      end,
      "hope mode",
      opts = { nowait = true },
    },
  },
}

return M
