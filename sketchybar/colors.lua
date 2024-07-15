-- Base on https://github.com/rebelot/kanagawa.nvim
return {
	black = 0xff090618,
	white = 0xffc8c093,
	red = 0xffc34043,
	green = 0xff76946a,
	blue = 0xff7e9cd8,
	yellow = 0xffc0a36e,
	orange = 0xffFFA066,
	magenta = 0xff957fb8,
	grey = 0xff727169,
	transparent = 0x00000000,

	bar = {
		bg = 0xff223249,
		border = 0xff54546D,
	},
	popup = {
		bg = 0xff2d4f67,
		border = 0xff54546D,
	},
	bg1 = 0xf016161D,
	bg2 = 0xff1f1f28,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
