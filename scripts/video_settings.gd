extends Node

var resolutions = [
	Vector2i(1024, 576),Vector2i(1152, 648),
	Vector2i(1280, 720),Vector2i(1280, 800),
	Vector2i(1360, 768),Vector2i(1366, 768),
	Vector2i(1440, 900),Vector2i(1600, 900),
	Vector2i(1680, 1050),Vector2i(1920, 1080)
]
var current_resolution_index = 0
var framerate_caps = [60, 120, 0]
var framerate_labels = ["60 FPS", "120 FPS", "OFF"]
var current_framerate_index = 0
var fullscreen_modes = ["Borderless", "OFF", "ON"]
var current_fullscreen_index = 0
var vsync_enabled = false

func _ready():
	load_settings()
	apply_all()

func apply_resolution():
	var res = resolutions[current_resolution_index]
	DisplayServer.window_set_size(res)

func apply_framerate():
	Engine.max_fps = framerate_caps[current_framerate_index]

func apply_fullscreen():
	match current_fullscreen_index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func apply_vsync():
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func apply_all():
	apply_resolution()
	apply_framerate()
	apply_fullscreen()
	apply_vsync()

func reset_defaults():
	current_resolution_index = 0
	current_framerate_index = 0
	current_fullscreen_index = 0
	vsync_enabled = false
	apply_all()
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("video", "resolution_index", current_resolution_index)
	config.set_value("video", "framerate_index", current_framerate_index)
	config.set_value("video", "fullscreen_index", current_fullscreen_index)
	config.set_value("video", "vsync", vsync_enabled)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		return
	current_resolution_index = config.get_value("video", "resolution_index", 0)
	current_framerate_index = config.get_value("video", "framerate_index", 0)
	current_fullscreen_index = config.get_value("video", "fullscreen_index", 0)
	vsync_enabled = config.get_value("video", "vsync", false)
