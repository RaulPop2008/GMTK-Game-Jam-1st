extends Node

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

func _ready():
	load_settings()
	apply_all_volumes()

func apply_master_volume():
	var bus_index = AudioServer.get_bus_index(MASTER_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))
	AudioServer.set_bus_mute(bus_index, master_volume <= 0.0)

func apply_music_volume():
	var bus_index = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(music_volume))
	AudioServer.set_bus_mute(bus_index, music_volume <= 0.0)

func apply_sfx_volume():
	var bus_index = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(sfx_volume))
	AudioServer.set_bus_mute(bus_index, sfx_volume <= 0.0)

func apply_all_volumes():
	apply_master_volume()
	apply_music_volume()
	apply_sfx_volume()

func save_settings():
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		return
	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 1.0)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
