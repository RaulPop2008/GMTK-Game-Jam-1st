extends Control

@onready var resolution_options: OptionButton=$VideoBackgroundUI/VideoMenuContainerUI/VideoOptionsContainerUI/ResolutionContainerUI/ResolutionOptionsUI
@onready var framecap_options: OptionButton=$VideoBackgroundUI/VideoMenuContainerUI/VideoOptionsContainerUI/FrameCapContainerUI/FrameCapOptionsUI
@onready var fullscreen_options: OptionButton=$VideoBackgroundUI/VideoMenuContainerUI/VideoOptionsContainerUI/FullScreenContainerUI/FullScreenOptionsUI
@onready var vsync_checkbutton: CheckButton=$VideoBackgroundUI/VideoMenuContainerUI/VideoOptionsContainerUI/VSyncContainerUI/VSyncCheckButtonUI
@onready var reset_defaults_button: Button=$VideoBackgroundUI/VideoMenuContainerUI/VideoOptionsContainerUI/ResetDefaultsButtonUI

func _ready():
	populate_dropdowns()
	connect_signals()
	update_ui()

func populate_dropdowns():
	resolution_options.clear()
	for res in VideoSettings.resolutions:
		resolution_options.add_item("%d x %d" % [res.x, res.y])
	framecap_options.clear()
	for label in VideoSettings.framerate_labels:
		framecap_options.add_item(label)
	fullscreen_options.clear()
	for mode in VideoSettings.fullscreen_modes:
		fullscreen_options.add_item(mode)

func connect_signals():
	resolution_options.item_selected.connect(on_resolution_selected)
	framecap_options.item_selected.connect(on_framecap_selected)
	fullscreen_options.item_selected.connect(on_fullscreen_selected)
	vsync_checkbutton.toggled.connect(on_vsync_toggled)
	reset_defaults_button.pressed.connect(on_reset_defaults_pressed)

func on_resolution_selected(index: int):
	VideoSettings.current_resolution_index = index
	VideoSettings.apply_resolution()
	VideoSettings.save_settings()

func on_framecap_selected(index: int):
	VideoSettings.current_framerate_index = index
	VideoSettings.apply_framerate()
	VideoSettings.save_settings()

func on_fullscreen_selected(index: int):
	VideoSettings.current_fullscreen_index = index
	VideoSettings.apply_fullscreen()
	VideoSettings.save_settings()

func on_vsync_toggled(toggled_on: bool):
	VideoSettings.vsync_enabled = toggled_on
	VideoSettings.apply_vsync()
	VideoSettings.save_settings()

func on_reset_defaults_pressed():
	VideoSettings.reset_defaults()
	update_ui()

func update_ui():
	resolution_options.select(VideoSettings.current_resolution_index)
	framecap_options.select(VideoSettings.current_framerate_index)
	fullscreen_options.select(VideoSettings.current_fullscreen_index)
	vsync_checkbutton.button_pressed = VideoSettings.vsync_enabled
