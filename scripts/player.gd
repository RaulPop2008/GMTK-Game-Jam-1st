extends CharacterBody2D

signal item_pickup(item_name:String)

const MOVEMENT_SPEED = 450.0

var is_paused:bool=false
var facing_direction:int=2
var pause_menu_open:bool=false
var can_pickup:bool=false
var item_name:String
var Nuts:int=0
var Bolts:int=0
var Cables:int
var new_animation:String
var current_animation:String
var can_do:bool=true
var can_move:bool=true
var is_crouching:bool=false

func _physics_process(delta: float) -> void:
	if can_do==true:
		Inputs()
		animation()
	move_and_slide()

func Inputs():
##----------------------------------------------------------
## MOVEMENT
##----------------------------------------------------------
	if Input.is_action_pressed("move_up"):
		velocity.y=-MOVEMENT_SPEED
		facing_direction=-2
	elif Input.is_action_pressed("move_down"):
		velocity.y=MOVEMENT_SPEED
		facing_direction=2
	else:
		velocity.y=0
	if Input.is_action_pressed("move_right"):
		velocity.x=MOVEMENT_SPEED
		facing_direction=1
	elif Input.is_action_pressed("move_left"):
		velocity.x=-MOVEMENT_SPEED
		facing_direction=-1
	else:
		velocity.x=0
##----------------------------------------------------------
## UI
##----------------------------------------------------------
	if Input.is_action_just_pressed("item_pickup") and can_pickup:
		item_pickup.emit(item_name)
		can_move=false
		is_crouching=true
		if item_name=="NutItem":
			Nuts+=1
		if item_name=="BoltItem":
			Bolts+=1
	if Input.is_action_just_pressed("ui_cancel") and is_paused==false:
		pass

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
	if current_animation!=new_animation:
		new_animation=current_animation
		$PlayerAnimations.play(new_animation)

func _on_player_pickup_zone_area_entered(area: Area2D) -> void:
	can_pickup=true
	item_name=area.name

func _on_player_pickup_zone_area_exited(area: Area2D) -> void:
	can_pickup=false
	item_name="0"

func _on_pause_menu_ui_pause_accepted(has_paused: bool) -> void:
	can_do=!has_paused

func _on_player_animations_animation_finished() -> void:
	is_crouching=false
	can_move=true
