local cal = sbar.add("item", {
	label = {
		width = 30,
		align = "right",
	},
	position = "right",
	update_freq = 15,
})

local function update()
	local time = os.date("%H:%M")
	cal:set({ label = time })
end

cal:subscribe("routine", update)
cal:subscribe("forced", update)
