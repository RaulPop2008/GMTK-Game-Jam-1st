extends Control

@onready var main_panel:Control=$MainMenuUI
@onready var options_panel:Control=$OptionsMenuUI
@onready var audio_panel:Control=$AudioMenuUI
@onready var video_panel:Control=$VideoMenuUI
@onready var credits_panel:Control=$CreditsMenuUI
@onready var guide_panel:Control=$GuideMenuUI
@onready var saves_panel:Control=$SavesMenuUI
@onready var ensure_panel:Control=$EnsureMenuUI

@onready var left_save_label:Label=$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/LeftSaveContainerUI/LeftSaveLabelUI
@onready var right_save_label:Label=$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/RightSaveContainerUI/RightSaveLabelUI
@onready var left_save_button:Button=$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/LeftSaveContainerUI/LeftSaveButtonUI
@onready var right_save_button:Button=$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/RightSaveContainerUI/RightSaveButtonUI

@onready var main_sound:AudioStreamWAV=preload("res://SFX/I came even longer.wav")

const NEW_SAVE_ICON:Texture2D=preload("res://sprites/pixil-frame-0 (23).png")
const LOAD_SAVE_ICON:Texture2D=preload("res://sprites/pixil-frame-0 (24).png")

var pending_delete_slot:int=1

func _ready():
	var player:=AudioStreamPlayer.new()
	player.bus="Music"
	player.stream=main_sound
	add_child(player)
	player.play()
	player.finished.connect(player.play)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/StartGameButtonUI.grab_focus()

	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/LeftSaveContainerUI/LeftSaveButtonUI.pressed.connect(on_left_save_pressed)
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/RightSaveContainerUI/RightSaveButtonUI.pressed.connect(on_right_save_pressed)
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/LeftTrashButtonUI.pressed.connect(on_left_trash_pressed)
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/RightTrashButtonUI.pressed.connect(on_right_trash_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/StartGameButtonUI.pressed.connect(on_start_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/OptionsButtonUI.pressed.connect(on_options_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/GuideButtonUI.pressed.connect(on_guide_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/CreditsButtonUI.pressed.connect(on_credits_pressed)
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/QuitGameButtonUI.pressed.connect(on_quit_pressed)
	$OptionsMenuUI/OptionsBackground/OptionsContainerUI/AudioVideoContainerUI/AudioButtonUI.pressed.connect(on_audio_pressed)
	$OptionsMenuUI/OptionsBackground/OptionsContainerUI/AudioVideoContainerUI/VideoButtonUI.pressed.connect(on_video_pressed)

	$EnsureMenuUI/Panel/EnsureMenuContainerUI/OptionsContainerUI/YesButtonUI.pressed.connect(on_yes_pressed)
	$EnsureMenuUI/Panel/EnsureMenuContainerUI/OptionsContainerUI/NoButtonUI.pressed.connect(on_no_pressed)
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/GoBackButtonSpecialUI.pressed.connect(on_go_back_main_pressed)
	$GuideMenuUI/GuideBackground/VBoxContainer/GoBackButtonUI.pressed.connect(on_go_back_main_pressed)
	$CreditsMenuUI/CreditsContainerUI/GoBackButtonUI.pressed.connect(on_go_back_main_pressed)
	$OptionsMenuUI/OptionsBackground/OptionsContainerUI/GoBackButtonUI.pressed.connect(on_go_back_main_pressed)
	$AudioMenuUI/AudioBackgroundUI/AudioMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)
	$VideoMenuUI/VideoBackgroundUI/VideoMenuContainerUI/GoBackButtonUI.pressed.connect(on_go_back_options_pressed)

	update_save_slot_previews()

func show_panel(panel: Control):
	for p in [main_panel,options_panel,guide_panel,credits_panel,audio_panel,video_panel,saves_panel,ensure_panel]:
		p.visible = (p == panel)

func update_save_slot_previews() -> void:
	var left_preview = SaveManager.get_save_preview(1)
	if left_preview.has_save:
		left_save_label.text = "Load Save"
		left_save_button.icon = LOAD_SAVE_ICON
		left_save_button.text = "Real Age: %d\nBody Age: %d" % [left_preview.real_age, left_preview.internal_age]
	else:
		left_save_label.text = "New Save"
		left_save_button.icon = NEW_SAVE_ICON
		left_save_button.text = ""

	var right_preview = SaveManager.get_save_preview(2)
	if right_preview.has_save:
		right_save_label.text = "Load Save"
		right_save_button.icon = LOAD_SAVE_ICON
		right_save_button.text = "Real Age: %d\nBody Age: %d" % [right_preview.real_age, right_preview.internal_age]
	else:
		right_save_label.text = "New Save"
		right_save_button.icon = NEW_SAVE_ICON
		right_save_button.text = ""

func on_left_trash_pressed():
	pending_delete_slot = 1
	$EnsureMenuUI/Panel/EnsureMenuContainerUI/OptionsContainerUI/NoButtonUI.grab_focus()
	show_panel(ensure_panel)

func on_right_trash_pressed():
	pending_delete_slot = 2
	$EnsureMenuUI/Panel/EnsureMenuContainerUI/OptionsContainerUI/NoButtonUI.grab_focus()
	show_panel(ensure_panel)

func on_yes_pressed():
	SaveManager.delete_save(pending_delete_slot)
	update_save_slot_previews()
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/GoBackButtonSpecialUI.grab_focus()
	show_panel(saves_panel)

func on_no_pressed():
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/GoBackButtonSpecialUI.grab_focus()
	show_panel(saves_panel)

func on_left_save_pressed():
	SaveManager.current_slot = 1
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func on_right_save_pressed():
	SaveManager.current_slot = 2
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func on_go_back_main_pressed():
	$MainMenuUI/MainContainerUI/MainMenuButtonsUI/StartGameButtonUI.grab_focus()
	show_panel(main_panel)

func on_go_back_options_pressed():
	$OptionsMenuUI/OptionsBackground/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_start_pressed():
	update_save_slot_previews()
	$SavesMenuUI/SavesMenuContainerUI/ButtonsContainerUI/GoBackButtonSpecialUI.grab_focus()
	show_panel(saves_panel)

func on_options_pressed():
	$OptionsMenuUI/OptionsBackground/OptionsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(options_panel)

func on_audio_pressed():
	$AudioMenuUI/AudioBackgroundUI/AudioMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(audio_panel)

func on_video_pressed():
	$VideoMenuUI/VideoBackgroundUI/VideoMenuContainerUI/GoBackButtonUI.grab_focus()
	show_panel(video_panel)

func on_guide_pressed():
	$GuideMenuUI/GuideBackground/VBoxContainer/GoBackButtonUI.grab_focus()
	show_panel(guide_panel)

func on_credits_pressed():
	$CreditsMenuUI/CreditsContainerUI/GoBackButtonUI.grab_focus()
	show_panel(credits_panel)

func on_quit_pressed():
	get_tree().quit()
