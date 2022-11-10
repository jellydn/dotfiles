local overrides = require "custom.plugins.overrides"

return {

  -- tabnine auto completion
  ["hrsh7th/nvim-cmp"] = {
    config = function()
      require "plugins.configs.cmp"
      require("custom.plugins.configs.tabnine").cmp()
    end,
  },

  ["tzachar/cmp-tabnine"] = {
    after = "nvim-cmp",
    run = "./install.sh",
    requires = "hrsh7th/nvim-cmp",
    config = function()
      require "custom.plugins.configs.tabnine"
    end,
  },

  -- outline
  ["stevearc/aerial.nvim"] = {
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension "aerial"
      require("aerial").setup {
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      }
    end,
  },

  -- enables dashboard
  ["goolord/alpha-nvim"] = {
    disable = false,
    override_options = overrides.alpha,
  },

  -- Override plugin definition options
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },

  -- rusttool
  ["simrat39/rust-tools.nvim"] = {
    override_options = overrides.rusttool,
  },

  -- TODO: setup golang

  -- overrde plugin configs
  ["nvim-treesitter/nvim-treesitter"] = {
    override_options = overrides.treesitter,
  },

  ["williamboman/mason.nvim"] = {
    override_options = overrides.mason,
  },

  ["kyazdani42/nvim-tree.lua"] = {
    override_options = overrides.nvimtree,
  },

  ["max397574/better-escape.nvim"] = {
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- autoclose tags in html, jsx only
  ["windwp/nvim-ts-autotag"] = {
    ft = { "html", "javascriptreact" },
    after = "nvim-treesitter",
    config = function()
      local present, autotag = pcall(require, "nvim-ts-autotag")

      if present then
        autotag.setup()
      end
    end,
  },

  -- code formatting, linting etc
  ["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
    config = function()
      require "custom.plugins.null-ls"
    end,
  },

  -- jump motions on speed
  ["phaazon/hop.nvim"] = {
    branch = "v2",
    config = function()
      require("hop").setup {}
    end,
  },

  -- Add/change/delete surrounding delimiter pairs with ease.
  ["kylechui/nvim-surround"] = {
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  -- remove plugin
  ["NvChad/nvterm"] = false,
}
