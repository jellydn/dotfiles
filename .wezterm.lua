-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- Resize font when user var changed
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
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
-- config.font = wezterm.font("OperatorMono Nerd Font")
-- Patch the ligature https://github.com/kiliman/operator-mono-lig then run font patcher for nerd font https://github.com/ryanoasis/nerd-fonts#font-patcher
config.font = wezterm.font("OperatorMonoLig Nerd Font")

-- config.font = wezterm.font("JetBrainsMono NF")
-- config.font_rules = {
-- 	{
-- 		intensity = "Bold",
-- 		italic = true,
-- 		font = wezterm.font({
-- 			family = "OperatorMonoLig Nerd Font",
-- 			weight = "Bold",
-- 			style = "Italic",
-- 		}),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Half",
-- 		font = wezterm.font({
-- 			family = "OperatorMonoLig Nerd Font",
-- 			weight = "DemiBold",
-- 			style = "Italic",
-- 		}),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Normal",
-- 		font = wezterm.font({
-- 			family = "OperatorMonoLig Nerd Font",
-- 			style = "Italic",
-- 		}),
-- 	},
-- }
config.font_size = 20

-- Hide tab bar when there is only one tab
config.hide_tab_bar_if_only_one_tab = true

-- Disable IME
config.use_ime = false

-- Set colorscheme
-- config.color_scheme = "Kanagawa (Gogh)"
-- local function scheme_for_appearance(appearance)
-- 	if appearance:find("Dark") then
-- 		return "Catppuccin Mocha"
-- 	else
-- 		return "Catppuccin Latte"
-- 	end
-- end
-- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

config.force_reverse_video_cursor = true
config.colors = {
	foreground = "#dcd7ba",
	background = "#1f1f28",

	cursor_bg = "#c8c093",
	cursor_fg = "#c8c093",
	cursor_border = "#c8c093",

	selection_fg = "#c8c093",
	selection_bg = "#2d4f67",

	scrollbar_thumb = "#16161d",
	split = "#16161d",

	ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
	brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
	indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}

-- Set window padding
config.window_padding = {
	left = 5,
	right = 5,
	top = 10,
	bottom = 0,
}

-- Set window decorations
config.window_decorations = "RESIZE"

-- Set transparency (0.0 - 1.0)
-- local is_transparent = true
-- if is_transparent then
-- 	config.window_background_opacity = 0.85
-- else
-- 	config.window_background_opacity = 1
-- end

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
