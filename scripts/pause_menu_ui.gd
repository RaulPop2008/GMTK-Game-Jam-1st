extends Control

signal pause_accepted(has_paused:bool)

var is_paused:bool=false
var is_inventory:bool=false

@onready var options_panel:Control=$OptionsMenuUI
@onready var audio_panel:Control=$AudioMenuUI
@onready var video_panel:Control=$VideoMenuUI
@onready var pause_panel:Control=$DarkPanelUI

func _ready() -> void:
	$DarkPanelUI/PauseMenuButtonsUI/ResumeButtonUI.pressed.connect(on_resume_pressed)
	$DarkPanelUI/PauseMenuButtonsUI/OptionsButtonUI.pressed.connect(on_options_pressed)
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/AudioVideoContainerUI/AudioButtonUI.pressed.connect(on_audio_pressed)
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/AudioVideoContainerUI/VideoButtonUI.pressed.connect(on_video_pressed)

	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/GoBackButtonUI.pressed.connect(on_go_back_pause_pressed)
	$AudioMenuUI/DarkPanelUI/AudioMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)
	$VideoMenuUI/DarkPanelUI/VideoMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and is_paused==false and is_inventory==false:
		pause_accepted.emit(true)
		is_inventory=true
		is_paused=true
		$DarkPanelUI.visible=true
		$DarkPanelUI/PauseMenuButtonsUI/ResumeButtonUI.grab_focus()
	if Input.is_action_just_pressed("open_inventory") and is_paused==false and is_inventory==false:
		is_inventory=true
		is_paused=true

func show_panel(panel: Control):
	for p in [options_panel,audio_panel,video_panel,pause_panel]:
		p.visible=(p==panel)

func on_resume_pressed():
	pause_accepted.emit(false)
	is_paused=false
	$DarkPanelUI.visible=false

func on_go_back_pause_pressed():
	$DarkPanelUI/PauseMenuButtonsUI/ResumeButtonUI.grab_focus()
	show_panel(pause_panel)

func on_go_back_options_pressed():
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_options_pressed():
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_audio_pressed():
	$AudioMenuUI/DarkPanelUI/AudioMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(audio_panel)

func on_video_pressed():
	$VideoMenuUI/DarkPanelUI/VideoMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(video_panel)
