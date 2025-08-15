local sbar = require("sketchybar")
local colors = require("colors")
local settings = require("settings")

local workspace = sbar.add("item", "aerospace", {
	position = "left",
	label = {
		string = "",
		color = colors.white,
		highlight_color = colors.green,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 20.0,
		},
		drawing = true,
	},
	padding_right = 12,
})

local function highlight_focused_workspace(env)
	sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
		for id in focused_workspace:gmatch("%S+") do
			local is_focused = tostring(id) == focused_workspace:match("%S+")
			sbar.animate("sin", 10, function()
				workspace:set({
					icon = {
						highlight = is_focused,
					},
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
workspace:subscribe("front_app_switched", highlight_focused_workspace)

-- Initially highlight the focused workspace
highlight_focused_workspace()

return workspace
