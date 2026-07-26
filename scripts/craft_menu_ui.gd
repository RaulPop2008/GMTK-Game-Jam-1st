extends Control

@onready var player:CharacterBody2D=$"../../Player"

func _ready() -> void:
	$Panel/VBoxContainer/MaskCraftButtonUI.grab_focus()
	$Panel/VBoxContainer/MaskCraftButtonUI.pressed.connect(on_mask_pressed)
	$Panel/VBoxContainer/SuitCraftButtonUI.pressed.connect(on_suit_pressed)
	$Panel/VBoxContainer/ArmCraftButtonUI.pressed.connect(on_arm_pressed)
	$Panel/VBoxContainer/LegCraftButtonUI.pressed.connect(on_leg_pressed)

func _process(delta: float) -> void:
	pass

func on_mask_pressed():
	if player.nuts>=2 and player.bolts>=2 and player.cables>=1:
		player.nuts-=2
		player.bolts-=2
		player.cables-=2
		player.mask+=1
	player.can_move=true
	visible=false

func on_suit_pressed():
	if player.nuts>=3 and player.bolts>=3 and player.cables>=1 and player.batteries>=3:
		player.nuts-=3
		player.bolts-=3
		player.cables-=1
		player.batteries-=3
		player.suit+=1
	player.can_move=true
	visible=false

func on_arm_pressed():
	if player.nuts>=3 and player.bolts>=3 and player.cables>=4 and player.batteries>=1:
		player.nuts-=3
		player.bolts-=3
		player.cables-=4
		player.batteries-=1
		player.arm+=1
	player.can_move=true
	visible=false

func on_leg_pressed():
	if player.nuts>=1 and player.bolts>=1 and player.cables>=1 and player.batteries>=1:
		player.nuts-=1
		player.bolts-=1
		player.cables-=1
		player.batteries-=1
		player.leg+=1
	player.can_move=true
	visible=false
