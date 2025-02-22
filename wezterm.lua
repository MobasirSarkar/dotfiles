local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font")

config.font_size = 15

config.window_decorations = "RESIZE"
config.colors = {
	background = "black",
}

config.color_scheme = "Ef-Maris-Dark"

config.macos_window_background_blur = 40
config.max_fps = 120

config.keys = {
	{
		key = "n",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}
config.window_background_image = "/home/mobasirsarkar/Pictures/digital-art-with-urban-landscape-architecture.jpg"
config.window_background_image_hsb = {
	brightness = 0.040,
	hue = 1.0,
	saturation = 1.0,
}
config.front_end = "Software"
config.text_background_opacity = 0.9
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Linear"
config.animation_fps = 120

return config
