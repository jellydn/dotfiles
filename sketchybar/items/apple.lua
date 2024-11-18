local colors = require("colors")
local icons = require("icons")

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
	icon = {
		font = { size = 16.0 },
		string = icons.apple,
		padding_right = 12,
		padding_left = 12,
	},
	label = {
		font = {
			size = 14.0,
			style = "Bold",
		},
		color = colors.white,
		highlight_color = colors.green,
		drawing = true,
	},
	background = {
		color = colors.bg2,
		border_color = colors.black,
		border_width = 1,
		padding_left = 4,
		padding_right = 4,
	},
	padding_left = 2,
	padding_right = 2,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

local function highlight_focused_workspace(env)
	sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
		for id in focused_workspace:gmatch("%S+") do
			local is_focused = tostring(id) == focused_workspace:match("%S+")
			sbar.animate("sin", 10, function()
				apple:set({
					label = {
						highlight = is_focused,
						string = id,
					},
				})
			end)
		end
	end)
end

-- Subscribe to the front_app_switched event to highlight the focused workspace
apple:subscribe("front_app_switched", highlight_focused_workspace)

-- Initially highlight the focused workspace
highlight_focused_workspace()

-- Double border for apple using a single item bracket
sbar.add("bracket", { apple.name }, {
	background = {
		color = colors.transparent,
		height = 30,
		border_color = colors.grey,
	},
})

-- Padding item required because of bracket
sbar.add("item", { width = 7 })
