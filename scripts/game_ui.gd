extends Control

@onready var main_panel:Control=$MainMenuUI
@onready var options_panel:Control=$OptionsMenuUI
@onready var audio_panel:Control=$AudioMenuUI
@onready var video_panel:Control=$VideoMenuUI
@onready var credits_panel:Control=$CreditsMenuUI

func _ready():
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/StartGameButtonUI.grab_focus()
	
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/StartGameButtonUI.pressed.connect(on_start_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/OptionsButtonUI.pressed.connect(on_options_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/CreditsButtonUI.pressed.connect(on_credits_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/QuitGameButtonUI.pressed.connect(on_quit_pressed)
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/AudioVideoContainerUI/AudioButtonUI.pressed.connect(on_audio_pressed)
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/AudioVideoContainerUI/VideoButtonUI.pressed.connect(on_video_pressed)

	$CreditsMenuUI/CreditsContainerUI/GoBackButtonUI.pressed.connect(on_go_back_main_pressed)
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/GoBackButtonUI.pressed.connect(on_go_back_main_pressed)
	$AudioMenuUI/DarkPanelUI/AudioMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)
	$VideoMenuUI/DarkPanelUI/VideoMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)

func show_panel(panel: Control):
	for p in [main_panel,options_panel,credits_panel,audio_panel,video_panel]:
		p.visible = (p == panel)

func on_go_back_main_pressed():
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/StartGameButtonUI.grab_focus()
	show_panel(main_panel)

func on_go_back_options_pressed():
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func on_options_pressed():
	$OptionsMenuUI/DarkPanelUI/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_audio_pressed():
	$AudioMenuUI/DarkPanelUI/AudioMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(audio_panel)

func on_video_pressed():
	$VideoMenuUI/DarkPanelUI/VideoMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(video_panel)

func on_credits_pressed():
	$CreditsMenuUI/CreditsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(credits_panel)

func on_quit_pressed():
	get_tree().quit()
