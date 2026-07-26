extends CharacterBody2D

signal item_pickup(item_name:String)
signal screen_shake(intensity:float)

const MOVEMENT_SPEED=450
const AGE_INCREASE_REQUIREMENT=36.5
const MASK_REDUCTION:float=0.45
const SUIT_REDUCTION:float=0.11
const ARM_INCREASE:float=0.65
const LEG_INCREASE:float=0.2

const VISION_BLUR_SCALE:float=3.0
const VISION_BLUR_CORNER_SIZE_BASE:float=0.4
const VISION_BLUR_CORNER_SIZE_MIN:float=0.05
const BRAIN_MISDIRECT_CHANCE_MULTIPLIER:float=50.0
const HAND_MISS_CHANCE_MULTIPLIER:float=100.0
const SHAKE_CHANCE_MULTIPLIER:float=100.0
const SHAKE_STRENGTH_MAX:float=90.0
var SHAKE_CHECK_INTERVAL:float=90.0

const LEG_FREEZE_CHANCE_MULTIPLIER:float=200.0
const LEG_FREEZE_DURATION:float=3.0
var LEG_FREEZE_CHECK_INTERVAL:float=60.0

const SLEEPY_FAINT_CHANCE:float=15.0
const SLEEPY_FADE_DURATION:float=1.0
const SLEEPY_BLACK_HOLD_DURATION:float=1.0
var SLEEPY_CHECK_INTERVAL:float=120.0

@export var debug_test_mode:bool=true

var is_paused:bool=false
var pause_menu_open:bool=false
var can_pickup:bool=false
var can_interact:bool=false
var item_name:String

var new_animation:String
var current_animation:String
var can_do:bool=true
var can_move:bool=true
var can_close:bool=false
var can_step:bool=true
var is_crouching:bool=false

var nuts:int=0
var bolts:int=0
var cables:int=0
var batteries:int=0
var real_age:int=19
var internal_age:int=19
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
var new_age:float
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
var shake_timer:float=0
var y_intent:int=0
var y_actual_sign:int=0
var x_intent:int=0
var x_actual_sign:int=0
var leg_freeze_timer:float=0
var is_leg_frozen:bool=false
var sleepy_timer:float=0
var is_fainted:bool=false

@onready var facing_direction:int=2
@onready var footstep_sound:AudioStreamMP3=preload("res://SFX/PM_FOLYFeet_Old_Creaky_Wood_Floor_Stairs_Footstep_Fast_6_PM_OWF_3614.mp3")
@onready var pickup_sound:AudioStreamMP3=preload("res://SFX/little_robot_sound_factory_Pickup_00.mp3")
@onready var corner_blur: ColorRect = $PlayerCanvas/BlurUI
@onready var player_camera: Camera2D = $PlayerCamera
var faint_overlay:ColorRect
var faint_label:Label

func _ready() -> void:
	_setup_faint_overlay()
	if debug_test_mode:
		_apply_debug_test_values()

func _setup_faint_overlay() -> void:
	var layer:=CanvasLayer.new()
	layer.layer=100
	add_child(layer)
	faint_overlay=ColorRect.new()
	faint_overlay.color=Color(0,0,0,0)
	faint_overlay.anchor_right=1.0
	faint_overlay.anchor_bottom=1.0
	faint_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	layer.add_child(faint_overlay)
	faint_label=Label.new()
	faint_label.text="You Fainted"
	faint_label.modulate=Color(1,1,1,0)
	faint_label.anchor_left=0.5
	faint_label.anchor_right=0.5
	faint_label.anchor_top=0.5
	faint_label.anchor_bottom=0.5
	faint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	faint_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	faint_label.add_theme_font_size_override("font_size",40)
	faint_label.add_theme_color_override("font_color",Color(1,1,1,1))
	faint_overlay.add_child(faint_label)

func _apply_debug_test_values() -> void:
	debuff_brain_multiplier=1.3      # sansa misdirect = (1.3-1)*50 = 15%
	debuff_hand_multiplier=1.3       # sansa miss pickup de baza = (1.3-1)*100 = 30%
	debuff_vision_multiplier=1.5     # blur vizibil imediat
	debuff_shaking_multiplier=1.3    # sansa shake = (1.3-1)*100 = 30%
	debuff_leg_multiplier=1.2        # sansa freeze = (1.2-1)*200 = 40%
	debuff_sleepy_multiplier=1.0
	debuff_breathing_multiplier=1.0
	SHAKE_CHECK_INTERVAL=5.0          # verifica shake-ul din 5 in 5 secunde, nu din 90 in 90
	LEG_FREEZE_CHECK_INTERVAL=8.0     # verifica freeze-ul din 8 in 8 secunde, nu din 60 in 60
	SLEEPY_CHECK_INTERVAL=10.0        # verifica faint-ul din 10 in 10 secunde, nu din 120 in 120

func _physics_process(delta: float) -> void:
	$PlayerPickupZone/PlayerPickupZoneHitBox.scale=Vector2(1+1*ARM_INCREASE*arm,1+1*ARM_INCREASE*arm)
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
	if is_leg_frozen:
		velocity.x=0
		velocity.y=0
		y_intent=0
		x_intent=0
	else:
		if Input.is_action_pressed("move_up") and can_move==true:
			if y_intent!=-1:
				y_intent=-1
				y_actual_sign=-1
				if brain_should_misdirect():
					y_actual_sign=1
			velocity.y=y_actual_sign*(MOVEMENT_SPEED+MOVEMENT_SPEED*LEG_INCREASE*leg)
			facing_direction=y_actual_sign*2
			step()
			can_step=false
		elif Input.is_action_pressed("move_down") and can_move==true:
			if y_intent!=1:
				y_intent=1
				y_actual_sign=1
				if brain_should_misdirect():
					y_actual_sign=-1
			velocity.y=y_actual_sign*(MOVEMENT_SPEED+MOVEMENT_SPEED*LEG_INCREASE*leg)
			facing_direction=y_actual_sign*2
			step()
			can_step=false
		else:
			velocity.y=0
			y_intent=0
		if Input.is_action_pressed("move_right") and can_move==true:
			if x_intent!=1:
				x_intent=1
				x_actual_sign=1
				if brain_should_misdirect():
					x_actual_sign=-1
			velocity.x=x_actual_sign*(MOVEMENT_SPEED+MOVEMENT_SPEED*LEG_INCREASE*leg)
			facing_direction=x_actual_sign
			step()
			can_step=false
		elif Input.is_action_pressed("move_left") and can_move==true:
			if x_intent!=-1:
				x_intent=-1
				x_actual_sign=-1
				if brain_should_misdirect():
					x_actual_sign=1
			velocity.x=x_actual_sign*(MOVEMENT_SPEED+MOVEMENT_SPEED*LEG_INCREASE*leg)
			facing_direction=x_actual_sign
			step()
			can_step=false
		else:
			velocity.x=0
			x_intent=0
##----------------------------------------------------------
## UI
##----------------------------------------------------------
	if Input.is_action_just_pressed("open_crafting") and can_interact and can_close==false:
		$"../WorldCanvas/CraftMenuUI/Panel/VBoxContainer/MaskCraftButtonUI".grab_focus()
		$"../WorldCanvas/CraftMenuUI".visible=true
		can_close=true
		can_move=false
	elif Input.is_action_just_pressed("open_crafting") and can_close==true:
		$"../WorldCanvas/CraftMenuUI".visible=false
		can_move=true
		can_close=false
	if Input.is_action_just_pressed("item_pickup") and can_pickup:
		can_move=false
		is_crouching=true
		if not hand_should_miss_pickup():
			item_pickup.emit(item_name)
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

func brain_should_misdirect() -> bool:
	var chance=(debuff_brain_multiplier-1)*BRAIN_MISDIRECT_CHANCE_MULTIPLIER
	return randf()*100.0<chance

func hand_should_miss_pickup() -> bool:
	var chance=(debuff_hand_multiplier-1)*HAND_MISS_CHANCE_MULTIPLIER
	var arm_reduction:float=clamp(ARM_INCREASE*arm/4.0,0.0,1.0)
	chance=chance*(1.0-arm_reduction)
	return randf()*100.0<chance

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
	var formula=(delta*1.2*debuff_brain_multiplier*(1+(debuff_breathing_multiplier-1)-((debuff_breathing_multiplier-1)*(MASK_REDUCTION*mask)))*debuff_hand_multiplier*debuff_leg_multiplier*debuff_shaking_multiplier*debuff_sleepy_multiplier*(1+(debuff_vision_multiplier-1)-((debuff_vision_multiplier-1)*(MASK_REDUCTION*mask/2))))
	real_age_counter+=delta
	internal_age_counter+=formula-formula*SUIT_REDUCTION*suit
	update_vision_blur()
	shake_timer+=delta
	if shake_timer>=SHAKE_CHECK_INTERVAL:
		shake_timer=0.0
		var shake_chance=(debuff_shaking_multiplier-1)*SHAKE_CHANCE_MULTIPLIER
		if randf()*100.0<shake_chance:
			screen_shake.emit(shake_chance/100.0)
			_apply_camera_shake(shake_chance/100.0)

	leg_freeze_timer+=delta
	if leg_freeze_timer>=LEG_FREEZE_CHECK_INTERVAL:
		leg_freeze_timer=0.0
		var freeze_chance=(debuff_leg_multiplier-1)*LEG_FREEZE_CHANCE_MULTIPLIER
		var leg_reduction:float=clamp(LEG_INCREASE*leg,0.0,1.0)
		freeze_chance=freeze_chance*(1.0-leg_reduction)
		if randf()*100.0<freeze_chance:
			_trigger_leg_freeze()

	sleepy_timer+=delta
	if sleepy_timer>=SLEEPY_CHECK_INTERVAL:
		sleepy_timer=0.0
		if has_debuff_sleepy and not is_fainted and randf()*100.0>SLEEPY_FAINT_CHANCE:
			_trigger_faint()

	has_debuff_brain=internal_age>=20
	has_debuff_leg=internal_age>=30
	has_debuff_hand=internal_age>=40
	has_debuff_vision=internal_age>=50
	has_debuff_sleepy=internal_age>=60
	has_debuff_breathing=internal_age>=70
	has_debuff_shaking=internal_age>=80

	if real_age_counter>=AGE_INCREASE_REQUIREMENT:
		real_age_counter=0
		real_age+=1
	if internal_age_counter>=AGE_INCREASE_REQUIREMENT:
		internal_age_counter=0
		internal_age+=1
		if has_debuff_brain:
			debuff_brain_multiplier+=0.01
		if has_debuff_leg:
			debuff_leg_multiplier+=0.01
		if has_debuff_hand:
			debuff_hand_multiplier+=0.01
		if has_debuff_vision:
			debuff_vision_multiplier+=0.01
		if has_debuff_sleepy:
			debuff_sleepy_multiplier+=0.01
		if has_debuff_breathing:
			debuff_breathing_multiplier+=0.01
		if has_debuff_shaking:
			debuff_shaking_multiplier+=0.01

func update_vision_blur():
	var impairment=(debuff_vision_multiplier-1)-((debuff_vision_multiplier-1)*(MASK_REDUCTION*mask/2))
	var blur_intensity=clamp(impairment*VISION_BLUR_SCALE,0.0,1.0)
	corner_blur.material.set_shader_parameter("intensity",blur_intensity)
	corner_blur.material.set_shader_parameter("corner_size",lerp(VISION_BLUR_CORNER_SIZE_BASE,VISION_BLUR_CORNER_SIZE_MIN,blur_intensity))

func _apply_camera_shake(intensity:float) -> void:
	var zoom_compensation:float=1.0/max(player_camera.zoom.x,0.01)
	var strength:float=clamp(intensity,0.0,1.0)*SHAKE_STRENGTH_MAX*zoom_compensation
	var original_offset:=player_camera.offset
	var elapsed:float=0.0
	var shake_duration:float=0.4
	var shake_step:float=0.02
	while elapsed<shake_duration:
		player_camera.offset=original_offset+Vector2(randf_range(-strength,strength),randf_range(-strength,strength))
		await get_tree().create_timer(shake_step).timeout
		elapsed+=shake_step
	player_camera.offset=original_offset

func _trigger_leg_freeze() -> void:
	is_leg_frozen=true
	await get_tree().create_timer(LEG_FREEZE_DURATION).timeout
	is_leg_frozen=false

func _trigger_faint() -> void:
	is_fainted=true
	can_move=false
	var fade_in:=create_tween()
	fade_in.tween_property(faint_overlay,"color:a",1.0,SLEEPY_FADE_DURATION)
	await fade_in.finished
	faint_label.modulate.a=1.0
	var roll=randf()*100.0
	var age_gain:int
	if roll<33.0:
		age_gain=1
	elif roll<66.0:
		age_gain=2
	else:
		age_gain=3
	internal_age+=age_gain
	await get_tree().create_timer(SLEEPY_BLACK_HOLD_DURATION).timeout
	faint_label.modulate.a=0.0
	var fade_out:=create_tween()
	fade_out.tween_property(faint_overlay,"color:a",0.0,SLEEPY_FADE_DURATION)
	await fade_out.finished
	can_move=true
	is_fainted=false

func step():
	if can_step:
		can_step = false
		await get_tree().create_timer(0.3).timeout
		var sfx := AudioStreamPlayer.new()
		sfx.bus = "SFX"
		sfx.stream = footstep_sound
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
		can_step = true

func _on_pause_menu_ui_pause_accepted(has_paused: bool) -> void:
	if is_fainted:
		return
	can_do=!has_paused

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

func _on_player_animations_animation_finished() -> void:
	is_crouching=false
	can_move=true

func _on_player_hit_box_area_entered(area: Area2D) -> void:
	if mask<1 or suit<1 or arm<1 or leg<1:
		pass
