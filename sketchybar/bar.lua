local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	height = 30,
	color = colors.bar.bg,
	border_color = colors.bar.border,
	shadow = true,
	sticky = true,
	padding_right = 10,
	padding_left = 10,
	blur_radius = 10,
	-- Remove the following line if you want to use the default bar position
	-- topmost = "window",
})
