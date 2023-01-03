local M = {}

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
