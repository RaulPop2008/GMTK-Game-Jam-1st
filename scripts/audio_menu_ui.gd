extends Control
@onready var master_slider:HSlider=$DarkPanelUI/AudioMenuContainerUI/LabelBarsContainerUI/BarsContainerUI/MasterVolumeSliderUI
@onready var music_slider:HSlider=$DarkPanelUI/AudioMenuContainerUI/LabelBarsContainerUI/BarsContainerUI/MusicVolumeSliderUI
@onready var sfx_slider:HSlider=$DarkPanelUI/AudioMenuContainerUI/LabelBarsContainerUI/BarsContainerUI/SFXVolumeSliderUI

func _ready():
	connect_signals()
	update_ui()

func connect_signals():
	master_slider.value_changed.connect(on_master_changed)
	music_slider.value_changed.connect(on_music_changed)
	sfx_slider.value_changed.connect(on_sfx_changed)

func on_master_changed(value:float):
	AudioSettings.master_volume=value
	AudioSettings.apply_master_volume()
	AudioSettings.save_settings()

func on_music_changed(value:float):
	AudioSettings.music_volume=value
	AudioSettings.apply_music_volume()
	AudioSettings.save_settings()

func on_sfx_changed(value:float):
	AudioSettings.sfx_volume=value
	AudioSettings.apply_sfx_volume()
	AudioSettings.save_settings()

func update_ui():
	master_slider.value=AudioSettings.master_volume
	music_slider.value=AudioSettings.music_volume
	sfx_slider.value=AudioSettings.sfx_volume
