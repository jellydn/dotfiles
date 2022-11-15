local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "typescript",
    "javascript",
    "graphql",
    "prisma",
    "tsx",
    "rust",
    "go",
    "toml",
    "c",
    "proto",
  },
  auto_install = true,
}

M.alpha = {
  header = {
    -- create by https://www.coolgenerator.com/ascii-text-generator
    val = {
      [[                                                        ]],
      [[      ██╗████████╗    ███╗   ███╗ █████╗ ███╗   ██╗     ]],
      [[      ██║╚══██╔══╝    ████╗ ████║██╔══██╗████╗  ██║     ]],
      [[      ██║   ██║       ██╔████╔██║███████║██╔██╗ ██║     ]],
      [[      ██║   ██║       ██║╚██╔╝██║██╔══██║██║╚██╗██║     ]],
      [[      ██║   ██║       ██║ ╚═╝ ██║██║  ██║██║ ╚████║     ]],
      [[      ╚═╝   ╚═╝       ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝     ]],
      [[                                                        ]],
    },
  },
}

M.mason = {
  ensure_installed = {
    -- common
    "codespell",
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "emmet-ls",
    "json-lsp",

    -- go
    "gopls",

    -- grpc
    "buf",
    "buf-language-server",
  },
}

M.rusttool = {
  ["rust-analyzer"] = {
    checkOnSave = {
      command = "clippy",
    },
  },
}

-- git support in nvimtree
M.nvimtree = {
  filters = {
    custom = { ".git" },
    exclude = { ".gitignore" },
  },

  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
