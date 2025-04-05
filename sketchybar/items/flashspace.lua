local colors = require("colors")
local settings = require("settings")

-- Mapping of workspace names to their display icons
local workspace_icons = {
	workspace = {
		Code = "􀤋",
		Terminal = "􀪏",
		Browser = "􀎬",
		Chat = "􀌤",
		Email = "􀍕",
		Design = "􀤒",
		Relax = "􀑪",
		Tools = "􀦳",
		Work = "􀉉",
		Apps = "􀏜",
		Default = "􀈊",
	},
}

-- Workspace Mapping Notes:
-- 1. Each workspace is mapped to a specific display (monitor) and has a unique shortcut
-- 2. Workspaces are sorted by:
--    - Display priority (external monitor first, then laptop)
--    - Shortcut number (opt+1, opt+2, etc.)
-- 3. Each workspace can have multiple apps associated with it
-- 4. The workspace icon is determined by the workspace name
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
			local ws_name = line:match('"id":"[^"]+","name":"([^"]+)"')
			local shortcut = line:match('"shortcut":"([^"]+)"')
			local display = line:match('"display":"([^"]+)"')

			local apps_json = line:match('"apps":(%[.-%])')
			if apps_json then
				for app_name in apps_json:gmatch('"name":"([^"]+)"') do
					app_to_workspace[app_name] = ws_name
				end
			end

			if ws_name and shortcut and display then
				return {
					name = ws_name,
					shortcut = shortcut,
					display = display,
					key = shortcut:match("opt%+(.)"),
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

	debug_log("Loaded workspaces: " .. #workspaces .. " workspaces loaded.")
	-- Dump all workspaces to debug log
	for _, ws in ipairs(workspaces) do
		debug_log("Workspace: " .. ws.name .. ", Shortcut: " .. ws.shortcut .. ", Display: " .. ws.display)
	end
	return workspaces
end

local function get_workspace_name(app_name)
	if not app_name or app_name == "" then
		return ""
	end
	return app_to_workspace[app_name] or ""
end

local function get_workspace_icon(workspace_name)
	return workspace_icons.workspace[workspace_name] or "􀈊" -- default icon
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

local function render_workspace_items_once(workspaces)
	workspace_items = {}

	for _, workspace in ipairs(workspaces) do
		debug_log("Rendering workspace item: " .. workspace.name)
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
	end
end

local function refresh_workspace_visibility()
	local current_display = get_active_display()
	debug_log("Refresh workspace for current display: " .. current_display)
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

	-- If app has been associated with a workspace, show the workspace icon
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
		-- Show the app name if no workspace is associated
		app_space:set({
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
	debug_log("Front app switched: " .. env.INFO)
	update_app_space(env.INFO)
	refresh_workspace_visibility()
end)

-- Load workspaces and create items at startup
cached_workspaces = load_workspaces()
-- Show workspaces on startup
render_workspace_items_once(cached_workspaces)
