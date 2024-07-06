local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 19.0,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 180,
})

local function battery_update()
	local file = assert(io.popen("pmset -g batt"))
	local batt_info = assert(file:read("a"))
	local icon = "!"

	if string.find(batt_info, "AC Power") then
		icon = icons.battery.charging
	else
		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
		end

		if found and charge > 80 then
			icon = icons.battery._100
		elseif found and charge > 60 then
			icon = icons.battery._75
		elseif found and charge > 40 then
			icon = icons.battery._50
		elseif found and charge > 20 then
			icon = icons.battery._25
		else
			icon = icons.battery._0
		end
	end

	battery:set({ icon = icon })
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.battery.padding", {
	position = "right",
	width = settings.group_paddings,
})
