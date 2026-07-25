extends Node2D

@onready var player: CharacterBody2D =$Player
@onready var dialogue_start: Control =$WorldCanvas/DialogueStart

func _ready() -> void:
	player.set_physics_process(false)
	var data = SaveManager.load_game(SaveManager.current_slot)
	if not data.is_empty():
		SaveManager.apply_save_to_player(data)
		_apply_collected_items(data.get("collected_items", []))

func _apply_collected_items(collected_items: Array) -> void:
	if not has_node("NutsBoltsCables"):
		return
	var container = get_node("NutsBoltsCables")
	for item_name in collected_items:
		if container.has_node(item_name):
			var item = container.get_node(item_name)
			item.visible = false
			if item.has_node("PickupArea"):
				item.get_node("PickupArea").disabled = true

func _on_player_item_pickup(item_name: String) -> void:
	get_node("NutsBoltsCables/"+item_name).set_deferred("visible",false)
	get_node("NutsBoltsCables/"+item_name+"/PickupArea").set_deferred("disabled",true)

func _on_dialogue_start_dialogue_finished() -> void:
	player.set_physics_process(true)
