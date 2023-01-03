require "custom.commands"

-- relative number as default
vim.opt.relativenumber = true

-- spell check
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.spellsuggest = "best,5"

-- Github Copilot
vim.g.copilot_assume_mapped = true
