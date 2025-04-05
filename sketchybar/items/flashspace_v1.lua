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

-- Monitor mapping
-- TODO: In the future, we should modify this to show workspaces per monitor
-- Current implementation shows all workspaces regardless of monitor
-- Future plan:
-- 1. Group workspaces by monitor
-- 2. Show only workspaces for the current monitor
-- 3. Add a way to switch between monitors
-- 4. Consider adding a monitor indicator in the bar
local MONITORS = {
	["S24R35xFZ"] = "Main", -- Your external monitor
	["Built-in Retina Display"] = "Laptop", -- Your laptop screen
}

-- Find main monitor from mapping
local main_monitor
for monitor, label in pairs(MONITORS) do
	if label == "Main" then
		main_monitor = monitor
		break
	end
end

-- local function debug_log(msg)
--     os.execute("echo '[flashspace] " .. msg .. "' >> /tmp/sketchybar_debug.log")
-- end

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

local function load_workspaces()
	-- NOTE: Make sure you have jq installed
	local cmd = "jq -r '.profiles[0].workspaces[] | tojson' " .. profiles_path
	local result = exec_cmd(cmd)
	local workspaces = {}

	for line in result:gmatch("[^\n]+") do
		local success, workspace = pcall(function()
			local name = line:match('"name":"([^"]+)"')
			local shortcut = line:match('"shortcut":"([^"]+)"')
			local display = line:match('"display":"([^"]+)"')
			local icon_path = line:match('"apps"%s*:%s*%[%s*{[^}]*"iconPath"%s*:%s*"([^"]+)"')

			if name and shortcut and display then
				local apps = line:match('"apps":(%[.-%])')
				if apps then
					for app in apps:gmatch('"name":"([^"]+)"') do
						app_to_workspace[app] = name
					end
				end
				return {
					name = name,
					shortcut = shortcut,
					display = display,
					key = shortcut:match("opt%+(.)"),
					icon_path = icon_path,
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
		if a.display == b.display then
			return a_num < b_num
		end
		return a.display == main_monitor
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

-- TODO: Implement proper click functionality
local function switch_to_workspace(workspace_key) end

-- TODO: Implement proper click handling for app_space
app_space:subscribe("mouse.clicked", function(env)
	local app_name = env.INFO
	if not app_name or app_name == "" then
		return
	end

	local workspace_name = get_workspace_name(app_name)
	if workspace_name ~= "" then
		local key = get_workspace_key(workspace_name)
		if key then
			switch_to_workspace(key)
		end
	end
end)

local workspace_items = {}

local function update_workspace_items()
	for _, item in pairs(workspace_items) do
		item:remove()
	end
	workspace_items = {}

	local last_display = nil

	for _, workspace in ipairs(cached_workspaces) do
		if last_display and last_display ~= workspace.display then
			local separator = sbar.add("item", "workspace.separator." .. workspace.display, {
				position = "left",
				padding_right = 8,
				padding_left = 8,
				label = {
					string = "|",
					font = {
						style = settings.font.style_map["Regular"],
						size = 12.0,
					},
					color = colors.grey,
				},
			})
			table.insert(workspace_items, separator)
		end

		local item = sbar.add("item", "workspace." .. workspace.name:lower(), {
			position = "left",
			padding_right = 8,
			padding_left = 8,
			background = {
				height = 26,
				color = colors.bg0,
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
				color = colors.white,
				padding_right = 4,
			},
			label = {
				string = workspace.key,
				font = {
					style = settings.font.style_map["Regular"],
					size = 12.0,
				},
				color = colors.white,
				padding_left = 0,
				padding_right = 6,
			},
			-- TODO: Implement proper click handling for workspace items
		})

		-- TODO: Implement proper double-click handling
		item:subscribe("mouse.double_clicked", function()
			switch_to_workspace(workspace.key)
		end)

		item:subscribe("mouse.entered", function()
			item:set({
				label = {
					string = string.format("%s - %s", workspace.key, workspace.name),
				},
				background = {
					color = colors.bg1,
				},
			})
		end)

		item:subscribe("mouse.exited", function()
			item:set({
				label = {
					string = workspace.key,
				},
				background = {
					color = colors.bg0,
				},
			})
		end)

		table.insert(workspace_items, item)
		last_display = workspace.display
	end
end

local function update_display(app_name)
	if not app_name or app_name == "" then
		app_space:set({ drawing = false })
		return
	end

	local workspace_name = get_workspace_name(app_name)
	local app_icon, display_name = get_app_info(app_name)

	if workspace_name ~= "" then
		local key = get_workspace_key(workspace_name)
		app_space:set({
			icon = {
				string = get_workspace_icon(workspace_name),
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

	update_workspace_items()
end

app_space:subscribe("front_app_switched", function(env)
	update_display(env.INFO)
end)

-- Load workspaces at startup
load_workspaces()
