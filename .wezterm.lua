-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

local function is_weekend()
	local day = tonumber(os.date("%w"))
	return day == 0 or day == 6
end

local function is_day_time()
	local hour = tonumber(os.date("%H"))
	return hour >= 9 and hour < 19
end

--- Set color scheme for window
---@param window any
local function apply_color_scheme(window)
	local overrides = window:get_config_overrides() or {}
	if is_day_time() and not is_weekend() then
		overrides.color_scheme = "Cobalt2"
		overrides.window_background_opacity = 0.85
	else
		overrides.color_scheme = "Dracula (Official)"
		overrides.window_background_opacity = 1
	end
	window:set_config_overrides(overrides)
end

-- Reload theme on update status
wezterm.on("update-status", function(window, pane)
	apply_color_scheme(window)
end)

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
wezterm.on("format-tab-title", function(tab, tabs)
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
-- Customize font rules
-- config.font_rules = {
-- 	{
-- 		intensity = "Bold",
-- 		italic = true,
-- 		font = wezterm.font({
-- 			family = "Operator Mono",
-- 			weight = "Bold",
-- 			style = "Italic",
-- 		}),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Half",
-- 		font = wezterm.font({
-- 			family = "Operator Mono",
-- 			weight = "DemiBold",
-- 			style = "Italic",
-- 		}),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Normal",
-- 		font = wezterm.font({
-- 			family = "Operator Mono",
-- 			style = "Italic",
-- 		}),
-- 	},
-- }
config.font_size = 18.5

-- Hide tab bar when there is only one tab
config.hide_tab_bar_if_only_one_tab = true

-- Disable IME
config.use_ime = false

-- Set colorscheme: Cobalt2 at datetime and Dracula at night
if is_day_time() and not is_weekend() then
	config.color_scheme = "Cobalt2"
else
	config.color_scheme = "Dracula (Official)"
end

-- Set window padding
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0, -- Tab bar is at bottom, so there is extra padding
}

-- Set window decorations
config.window_decorations = "RESIZE"

-- Set native macos full screen - Not working nicely
config.native_macos_fullscreen_mode = true

-- Set transparency (0.0 - 1.0)
if is_day_time() and not is_weekend() then
	config.window_background_opacity = 0.85
end

-- Setup background image
-- config.background = {
-- 	{
-- 		source = { File = "/Users/huynhdung/Downloads/coding.jpg" },
-- 		-- When the viewport scrolls, move this layer 10% of the number of
-- 		-- pixels moved by the main viewport. This makes it appear to be
-- 		-- further behind the text.
-- 		repeat_x = "Mirror",
-- 		hsb = {
-- 			-- Reduce the brightness by 10%
-- 			brightness = 0.1,
-- 		},
-- 	},
-- }

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
	-- Clear console with CMD + K
	{ key = "k", mods = "SUPER", action = wezterm.action({ ClearScrollback = "ScrollbackAndViewport" }) },
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
