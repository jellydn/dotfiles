local colors = require("colors")
local settings = require("settings")
local workspace_icons = require("items.icons.workspace")

-- Workspace Mapping Notes:
-- 1. Each workspace is mapped to a specific display (monitor) and has a unique shortcut
-- 2. Workspaces are sorted by:
--    - Display priority (external monitor first, then laptop)
--    - Shortcut number (opt+1, opt+2, etc.)
-- 3. Each workspace can have multiple apps associated with it
-- 4. The workspace icon is determined by the first app's icon in the workspace
-- 5. App-to-workspace mapping is cached for quick lookups
-- 6. Future improvements:
--    - Group workspaces by monitor
--    - Show only workspaces for current monitor
--    - Add monitor switching capability
--    - Add monitor indicator in the bar

local profiles_path = os.getenv("HOME") .. "/.config/flashspace/profiles.json"

-- Cache for workspaces and app mappings
local cached_workspaces = {}
local app_to_workspace = {}

-- Table to hold references to created workspace items (keyed by workspace name)
local workspace_items = {}

local function debug_log(msg)
	os.execute("echo '[flashspace] " .. msg .. "' >> /tmp/sketchybar_debug.log")
end

local function exec_cmd(cmd)
	local handle = io.popen(cmd .. " 2>&1")
	if not handle then
		return "", false
	end
	local result = handle:read("*a")
	handle:close()
	result = result and result:gsub("%s+$", "") or ""
	return result, result ~= ""
end

local function get_active_display()
	local cmd = "/usr/local/bin/flashspace get-display"
	local result, success = exec_cmd(cmd)
	if success then
		return result
	else
		return ""
	end
end

local function load_workspaces()
	-- NOTE: Make sure you have jq installed
	local cmd = "jq -r '.profiles[0].workspaces[] | tojson' " .. profiles_path
	local result = exec_cmd(cmd)
	local workspaces = {}

	for line in result:gmatch("[^\n]+") do
		local success, workspace = pcall(function()
			-- Try to extract fields more specifically
			-- Look for name after id, display after assignAppShortcut/apps
			local ws_name = line:match('"id":"[^"]+","name":"([^"]+)"')
			local shortcut = line:match('"shortcut":"([^"]+)"')
			local display = line:match('"display":"([^"]+)"')
			-- Keep the first app icon path logic as is
			local first_app_icon_path = line:match('"apps"%s*:%s*%[%s*{[^}]*"iconPath"%s*:%s*"([^"]+)"')

			if ws_name and shortcut and display then
				local apps_json = line:match('"apps":(%[.-%])')
				if apps_json then
					for app_name in apps_json:gmatch('"name":"([^"]+)"') do
						-- Use the correctly extracted ws_name for the mapping
						app_to_workspace[app_name] = ws_name
					end
				end
				return {
					name = ws_name, -- Use the correct workspace name
					shortcut = shortcut,
					display = display,
					key = shortcut:match("opt%+(.)"),
					icon_path = first_app_icon_path,
				}
			end
			return nil
		end)

		if success and workspace then
			table.insert(workspaces, workspace)
		end
	end

	table.sort(workspaces, function(a, b)
		local a_num = tonumber(a.key) or 0
		local b_num = tonumber(b.key) or 0
		return a_num < b_num
	end)

	cached_workspaces = workspaces
	return workspaces
end

local function get_workspace_name(app_name)
	if not app_name or app_name == "" then
		return ""
	end
	return app_to_workspace[app_name] or ""
end

local function get_workspace_icon(workspace_name)
	for _, workspace in ipairs(cached_workspaces) do
		if workspace.name == workspace_name then
			if workspace.icon_path then
				-- NOTE: Add mapping when we have a new app to workspace
				local icon_map = {
					["Warp.icns"] = workspace_icons.workspace.Terminal,
					["Cursor.icns"] = workspace_icons.workspace.Code,
					["Code - Insiders.icns"] = workspace_icons.workspace.Code,
					["Zed Preview.icns"] = workspace_icons.workspace.Code,
					["AppIcon.icns"] = workspace_icons.workspace.Terminal,
					["electron.icns"] = workspace_icons.workspace.Apps,
					["app.icns"] = workspace_icons.workspace.Browser,
					["firefox.icns"] = workspace_icons.workspace.Browser,
					["icon.icns"] = workspace_icons.workspace.Email,
					["messenger.icns"] = workspace_icons.workspace.Chat,
					["Icon.icns"] = workspace_icons.workspace.Media,
					["Navicat Premium Lite.icns"] = workspace_icons.workspace.Tools,
					["ZPLogo.icns"] = workspace_icons.workspace.Design,
					["figma.icns"] = workspace_icons.workspace.Design,
					["spotify.icns"] = workspace_icons.workspace.Media,
					["Slack.icns"] = workspace_icons.workspace.Tools,
				}

				local icon_file = workspace.icon_path:match("/([^/]+)$")
				if icon_file then
					local icon = icon_map[icon_file]
					if icon then
						return icon
					end
				end
			end
		end
	end

	return "􀈊" -- default icon
end

local function get_app_info(app_name)
	if not app_name or app_name == "" then
		return workspace_icons.apps.default, ""
	end
	local display_name = app_name:gsub(" Browser$", ""):gsub("^Microsoft ", "")
	local app_icon = workspace_icons.apps[app_name] or workspace_icons.apps.default
	return app_icon, display_name
end

local function get_workspace_key(workspace_name)
	for _, workspace in ipairs(cached_workspaces) do
		if workspace.name == workspace_name then
			return workspace.key
		end
	end
	return nil
end

-- Create the combined item
local app_space = sbar.add("item", "app.space", {
	position = "left",
	padding_right = 12,
	padding_left = 8,
	background = {
		color = colors.bg1,
		border_width = 1,
		height = 26,
		corner_radius = 5,
		border_color = colors.blue,
	},
	label = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 12.0,
		},
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
	},
	updates = true,
})

local function switch_to_workspace(workspace_name)
	if not workspace_name then
		return
	end
	local cmd = "/usr/local/bin/flashspace workspace --name " .. workspace_name
	os.execute(cmd)
end

local function create_workspace_items_once()
	for _, item in pairs(workspace_items) do
		if item and type(item.remove) == "function" then
			item:remove()
		end
	end
	workspace_items = {}

	local last_display_iterated = nil
	for i, workspace in ipairs(cached_workspaces) do
		local item_name = "workspace." .. workspace.name:lower()
		local item = sbar.add("item", item_name, {
			position = "left",
			drawing = false, -- Start hidden
			padding_right = 8,
			padding_left = 8,
			background = {
				height = 26,
				color = colors.bg0, -- Initial background
				border_width = 0,
				corner_radius = 5,
			},
			icon = {
				string = get_workspace_icon(workspace.name),
				font = {
					family = "SF Pro",
					style = "Regular",
					size = 14.0,
				},
				color = colors.grey, -- Initial color (inactive)
				padding_right = 4,
			},
			label = {
				string = "", -- Start with empty label
				width = 0, -- Start with zero width
				font = {
					style = settings.font.style_map["Regular"],
					size = 12.0,
				},
				color = colors.white, -- Color when shown (but initially hidden by width)
			},
			animate = true,
			animation = { duration = 0.3 }, -- Add animation properties
		})

		-- Keep hover/click effects
		item:subscribe("mouse.clicked", function()
			debug_log("Clicked on workspace: " .. workspace.name .. ", key: " .. tostring(workspace.key))
			switch_to_workspace(workspace.name)
		end)

		item:subscribe("mouse.entered", function()
			item:set({
				-- Reveal label on hover
				label = {
					string = string.format("%s - %s", workspace.key, workspace.name),
					width = "dynamic",
				},
				background = {
					color = colors.bg1,
				},
			})
		end)

		item:subscribe("mouse.exited", function()
			-- Hide label on exit
			item:set({
				label = {
					string = "",
					width = 0,
				},
				-- Reset colors (already white from refresh_workspace_visibility)
				-- icon = { color = colors.white },
				-- label = { color = colors.white },
				background = {
					color = colors.bg0,
				},
			})
		end)

		-- Store the item reference keyed by workspace name
		workspace_items[workspace.name] = item
		last_display_iterated = workspace.display
	end
end

local function refresh_workspace_visibility()
	local current_display = get_active_display()
	for _, workspace in ipairs(cached_workspaces) do
		local item = workspace_items[workspace.name]
		if item then
			local should_draw = (workspace.display == current_display)
			item:set({
				drawing = should_draw,
				icon = { color = colors.white },
				label = { color = colors.white },
			})
		end
	end
end

local function update_app_space(app_name)
	if not app_name or app_name == "" then
		app_space:set({ drawing = false })
		return
	end

	local workspace_name = get_workspace_name(app_name)
	local app_icon, _ = get_app_info(app_name)

	if workspace_name ~= "" then
		local key = get_workspace_key(workspace_name)
		local workspace_icon = get_workspace_icon(workspace_name)
		app_space:set({
			icon = {
				string = workspace_icon,
				font = {
					family = "SF Pro",
					style = "Regular",
					size = 14.0,
				},
				color = colors.white,
				padding_right = 4,
			},
			label = {
				string = string.format("%s - %s", key and "W" .. key or "", app_name),
				color = colors.white,
			},
			drawing = true,
			background = {
				color = colors.bg1,
				border_width = 1,
				height = 26,
				corner_radius = 5,
				border_color = colors.blue,
			},
		})
	else
		app_space:set({
			icon = {
				string = app_icon,
				font = {
					family = "SF Pro",
					style = "Regular",
					size = 14.0,
				},
				color = colors.white,
				padding_right = 4,
			},
			label = {
				string = app_name,
				color = colors.white,
			},
			drawing = true,
			background = {
				color = colors.bg1,
				border_width = 1,
				height = 26,
				corner_radius = 5,
				border_color = colors.grey,
			},
		})
	end
end

app_space:subscribe("front_app_switched", function(env)
	update_app_space(env.INFO)
	refresh_workspace_visibility()
end)

-- Load workspaces and create items at startup
load_workspaces()
-- Show workspaces on startup
create_workspace_items_once()
-- Refresh workspace visibility
refresh_workspace_visibility()
