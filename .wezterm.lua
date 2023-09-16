-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- Full screen on startup, refer
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
end)

local tab_title = function(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

-- Format title
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- Not sure if it will slow down the performance, at least so far it's good
	-- Is there a better way to get the tab or window cols ?
	local mux_window = wezterm.mux.get_window(tab.window_id)
	local mux_tab = mux_window:active_tab()
	local mux_tab_cols = mux_tab:get_size().cols

	-- Calculate active/inactive tab cols
	-- In general, active tab cols > inactive tab cols
	local tab_count = #tabs
	local inactive_tab_cols = math.floor(mux_tab_cols / tab_count)
	local active_tab_cols = mux_tab_cols - (tab_count - 1) * inactive_tab_cols

	local title = tab_title(tab)
	title = " " .. title .. " "
	local title_cols = wezterm.column_width(title)
	local icon = " ⦿"
	local icon_cols = wezterm.column_width(icon)

	-- Divide into 3 areas and center the title
	if tab.is_active then
		local rest_cols = math.max(active_tab_cols - title_cols, 0)
		local right_cols = math.ceil(rest_cols / 2)
		local left_cols = rest_cols - right_cols
		return {
			-- left
			{ Foreground = { Color = "Fuchsia" } },
			{ Text = wezterm.pad_right(icon, left_cols) },
			-- center
			{ Foreground = { Color = "#46BDFF" } },
			{ Attribute = { Italic = true } },
			{ Text = title },
			-- right
			{ Text = wezterm.pad_right("", right_cols) },
		}
	else
		local rest_cols = math.max(inactive_tab_cols - title_cols, 0)
		local right_cols = math.ceil(rest_cols / 2)
		local left_cols = rest_cols - right_cols
		return {
			-- left
			{ Text = wezterm.pad_right("", left_cols) },
			-- center
			{ Attribute = { Italic = true } },
			{ Text = title },
			-- right
			{ Text = wezterm.pad_right("", right_cols) },
		}
	end
end)

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Setup font and font size
config.font = wezterm.font("JetBrainsMono NF")
config.font_size = 17.0

-- Hide tab bar when there is only one tab
config.hide_tab_bar_if_only_one_tab = true

-- Disable IME
config.use_ime = false

-- Set colorscheme
config.color_scheme = "Cobalt2"

-- Set window padding
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Set window decorations
config.window_decorations = "RESIZE"

-- Set native macos full screen
config.native_macos_fullscreen_mode = true

-- Set transparency (0.0 - 1.0)
config.window_background_opacity = 0.85

-- Do not show confirmation dialog when quitting
config.window_close_confirmation = "NeverPrompt"

-- Set tab bar position
config.tab_bar_at_bottom = true

-- More keybindings on https://wezfurlong.org/wezterm/config/default-keys.html
config.keys = {
	-- Disable resize font with ctrl +/-
	{ key = "=", mods = "CTRL", action = "DisableDefaultAssignment" },
	{ key = "-", mods = "CTRL", action = "DisableDefaultAssignment" },
	-- Split horizontal pane with CMD + d
	{ key = "d", mods = "SUPER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	-- Split vertical pane with CMD + s
	{ key = "s", mods = "SUPER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	-- Close pane with CMD + w
	{ key = "w", mods = "SUPER", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
	-- Navigate between panes with CMD + hjkl
	{ key = "h", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "l", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	{ key = "j", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
}

-- Hyperlink rule
config.hyperlink_rules = {
	-- Linkify things that look like URLs
	-- This is actually the default if you don't specify any hyperlink_rules
	{
		regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
		format = "$0",
	},

	-- match the URL with a PORT
	-- such 'http://localhost:3000/index.html'
	{
		regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b",
		format = "$0",
	},

	-- linkify email addresses
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},

	-- file:// URI
	{
		regex = "\\bfile://\\S*\\b",
		format = "$0",
	},
}

-- and finally, return the configuration to wezterm
return config
