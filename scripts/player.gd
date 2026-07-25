extends CharacterBody2D

signal item_pickup(item_name:String)

const MOVEMENT_SPEED=450
const AGE_INCREASE_REQUIREMENT=29

var is_paused:bool=false
var pause_menu_open:bool=false
var can_pickup:bool=false
var can_interact:bool=false
var item_name:String

var new_animation:String
var current_animation:String
var can_do:bool=true
var can_move:bool=true
var is_crouching:bool=false

var nuts:int=0
var bolts:int=0
var cables:int
var batteries:int=0
var real_age:int=21
var internal_age:int=21
var has_mask:bool=false
var has_suit:bool=false
var has_arm:bool=false
var has_leg:bool=false
var mask:int=0
var suit:int=0
var arm:int=0
var leg:int=0
var has_debuff_brain:bool=false
var has_debuff_leg:bool=false
var has_debuff_hand:bool=false
var has_debuff_vision:bool=false
var has_debuff_sleepy:bool=false
var has_debuff_breathing:bool=false
var has_debuff_shaking:bool=false
@onready var debuff_brain_multiplier:float=1
@onready var debuff_leg_multiplier:float=1
@onready var debuff_hand_multiplier:float=1
@onready var debuff_vision_multiplier:float=1
@onready var debuff_sleepy_multiplier:float=1
@onready var debuff_breathing_multiplier:float=1
@onready var debuff_shaking_multiplier:float=1
var collected_items:Array[String]

var real_age_counter:float=0
var internal_age_counter:float=0

@onready var facing_direction:int=2
@onready var pickup_sound:AudioStreamMP3=preload("res://SFX/little_robot_sound_factory_Pickup_00.mp3")

func _physics_process(delta: float) -> void:
	show_debuff_multiplier()
	show_item_count()
	if can_do==true:
		Inputs()
		animation()
		age_calculator(delta)
	else:
		velocity.x=0
		velocity.y=0
		$PlayerAnimations.animation="idle_down"
	move_and_slide()

func Inputs():
##----------------------------------------------------------
## MOVEMENT
##----------------------------------------------------------
	if Input.is_action_pressed("move_up") and can_move==true:
		velocity.y=-MOVEMENT_SPEED
		facing_direction=-2
	elif Input.is_action_pressed("move_down") and can_move==true:
		velocity.y=MOVEMENT_SPEED
		facing_direction=2
	else:
		velocity.y=0
	if Input.is_action_pressed("move_right") and can_move==true:
		velocity.x=MOVEMENT_SPEED
		facing_direction=1
	elif Input.is_action_pressed("move_left") and can_move==true:
		velocity.x=-MOVEMENT_SPEED
		facing_direction=-1
	else:
		velocity.x=0
##----------------------------------------------------------
## UI
##----------------------------------------------------------
	if Input.is_action_just_pressed("open_crafting") and can_interact:
		$"../WorldCanvas/CraftMenuUI/Panel/VBoxContainer/MaskCraftButtonUI".grab_focus()
		$"../WorldCanvas/CraftMenuUI".visible=true
		can_move=false
	if Input.is_action_just_pressed("item_pickup") and can_pickup:
		item_pickup.emit(item_name)
		can_move=false
		is_crouching=true
		if item_name.contains("NutItem"):
			nuts+=1
		if item_name.contains("BoltItem"):
			bolts+=1
		if item_name.contains("CablesItem"):
			cables+=1
		if item_name.contains("Batteriesitem"):
			batteries+=1
		if item_name not in collected_items:
			collected_items.append(item_name)
		await get_tree().create_timer(0.5).timeout
		var player:=AudioStreamPlayer.new()
		player.bus="SFX"
		player.stream=pickup_sound
		player.volume_db=-20
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)

func animation():
	if facing_direction==1 and is_crouching==true:
		current_animation="crouch_right"
	elif facing_direction==-1 and is_crouching==true:
		current_animation="crouch_left"
	elif facing_direction==2 and is_crouching==true:
		current_animation="crouch_down"
	elif facing_direction==-2 and is_crouching==true:
		current_animation="crouch_up"
	elif facing_direction==1 and velocity.x==0 and velocity.y==0:
		current_animation="idle_right"
	elif facing_direction==-1 and velocity.x==0 and velocity.y==0:
		current_animation="idle_left"
	elif facing_direction==2 and velocity.y==0 and velocity.x==0:
		current_animation="idle_down"
	elif facing_direction==-2 and velocity.y==0 and velocity.x==0:
		current_animation="idle_up"
	elif facing_direction==1 and velocity.x!=0:
		current_animation="walk_right"
	elif facing_direction==-1 and velocity.x!=0:
		current_animation="walk_left"
	elif facing_direction==2 and velocity.y!=0:
		current_animation="walk_down"
	elif facing_direction==-2 and velocity.y!=0:
		current_animation="walk_up"
	elif is_paused==true:
		current_animation="idle_down"
	if current_animation!=new_animation:
		new_animation=current_animation
		$PlayerAnimations.play(new_animation)

func show_item_count():
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer/Label.text=str(nuts)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer2/Label.text=str(bolts)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer3/Label.text=str(cables)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer4/Label.text=str(batteries)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer5/Label.text=str(mask)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer6/Label.text=str(suit)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer7/Label.text=str(arm)
	$PlayerCanvas/ItemsEquipmentContainerUI/HBoxContainer8/Label.text=str(leg)

func show_debuff_multiplier():
	$PlayerCanvas/DebuffsContainerUI/BlurContainerUI/Label.text="x"+str(debuff_vision_multiplier)
	$PlayerCanvas/DebuffsContainerUI/BreatheContainerUI/Label.text="x"+str(debuff_breathing_multiplier)
	$PlayerCanvas/DebuffsContainerUI/BrainContainerUI/Label.text="x"+str(debuff_brain_multiplier)
	$PlayerCanvas/DebuffsContainerUI/HandContainerUI/Label.text="x"+str(debuff_hand_multiplier)
	$PlayerCanvas/DebuffsContainerUI/ShakeContainerUI/Label.text="x"+str(debuff_shaking_multiplier)
	$PlayerCanvas/DebuffsContainerUI/LegContainerUI/Label.text="x"+str(debuff_leg_multiplier)
	$PlayerCanvas/DebuffsContainerUI/SleepContainerUI/Label.text="x"+str(debuff_sleepy_multiplier)

func age_calculator(delta:float):
	$PlayerCanvas/AgeContainerUI/RealAgeLabelUI.text="Real Age: "+str(real_age)
	$PlayerCanvas/AgeContainerUI/BodyAgeLabelUI.text="Body Internal Age: "+str(internal_age)
	real_age_counter+=delta
	internal_age_counter+=(delta*1.2*debuff_brain_multiplier*debuff_breathing_multiplier*debuff_hand_multiplier*debuff_leg_multiplier*debuff_shaking_multiplier*debuff_sleepy_multiplier*debuff_vision_multiplier)
	if real_age_counter>=AGE_INCREASE_REQUIREMENT:
		real_age_counter=0
		real_age+=1
	if internal_age_counter>=AGE_INCREASE_REQUIREMENT:
		internal_age_counter=0
		internal_age+=1

func _on_player_pickup_zone_area_entered(area: Area2D) -> void:
	can_pickup=true
	item_name=area.name

func _on_player_pickup_zone_area_exited(area: Area2D) -> void:
	can_pickup=false
	item_name="0"

func _on_player_interaction_zone_area_entered(area: Area2D) -> void:
	can_interact=true

func _on_player_interaction_zone_area_exited(area: Area2D) -> void:
	can_interact=false

func _on_pause_menu_ui_pause_accepted(has_paused: bool) -> void:
	can_do=!has_paused

func _on_player_animations_animation_finished() -> void:
	is_crouching=false
	can_move=true
