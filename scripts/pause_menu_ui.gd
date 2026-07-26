extends Control

signal pause_accepted(has_paused:bool)

var is_paused:bool=false
var is_inventory:bool=false

var nuts:int=0
var bolts:int=0
var cables:int=0
var batteries:int=0

@onready var options_panel:Control=$OptionsMenuUI
@onready var audio_panel:Control=$AudioMenuUI
@onready var video_panel:Control=$VideoMenuUI
@onready var pause_panel:Control=$DarkPanelUI

func _ready() -> void:
	$DarkPanelUI/PauseMenuButtonsUI/ResumeButtonUI.pressed.connect(on_resume_pressed)
	$DarkPanelUI/PauseMenuButtonsUI/OptionsButtonUI.pressed.connect(on_options_pressed)
	$"DarkPanelUI/PauseMenuButtonsUI/Save&QuitButtonUI".pressed.connect(on_quit_pressed)
	$OptionsMenuUI/OptionsBackgroundUI/OptionsContainerUI/AudioVideoContainerUI/AudioButtonUI.pressed.connect(on_audio_pressed)
	$OptionsMenuUI/OptionsBackgroundUI/OptionsContainerUI/AudioVideoContainerUI/VideoButtonUI.pressed.connect(on_video_pressed)

	$OptionsMenuUI/OptionsBackgroundUI/OptionsContainerUI/GoBackButtonUI.pressed.connect(on_go_back_pause_pressed)
	$AudioMenuUI/AudioBackgroundUI/AudioMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)
	$VideoMenuUI/VideoBackgroundUI/VideoMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and is_paused==false and $"../CraftMenuUI".visible==false:
		pause_accepted.emit(true)
		is_paused=true
		$DarkPanelUI.visible=true
		$DarkPanelUI/PauseMenuButtonsUI/ResumeButtonUI.grab_focus()

func show_panel(panel: Control):
	for p in [options_panel,audio_panel,video_panel,pause_panel]:
		p.visible=(p==panel)

func on_resume_pressed():
	pause_accepted.emit(false)
	is_paused=false
	is_inventory=false
	$DarkPanelUI.visible=false

func on_quit_pressed():
	SaveManager.save_game(SaveManager.current_slot)
	$DarkPanelUI.visible=false
	get_tree().change_scene_to_file("res://scenes/game_ui.tscn")

func on_go_back_pause_pressed():
	$DarkPanelUI/PauseMenuButtonsUI/ResumeButtonUI.grab_focus()
	show_panel(pause_panel)

func on_go_back_options_pressed():
	$OptionsMenuUI/OptionsBackgroundUI/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_options_pressed():
	$OptionsMenuUI/OptionsBackgroundUI/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_audio_pressed():
	$AudioMenuUI/AudioBackgroundUI/AudioMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(audio_panel)

func on_video_pressed():
	$VideoMenuUI/VideoBackgroundUI/VideoMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(video_panel)
