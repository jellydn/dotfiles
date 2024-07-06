local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	-- topmost = "window",
	height = 30,
	color = colors.transparent,
	shadow = true,
	sticky = true,
	padding_right = 10,
	padding_left = 10,
	blur_radius = 10,
})
