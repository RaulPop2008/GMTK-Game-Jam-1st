extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_player_item_pickup(item_name: String) -> void:
	get_node("NutsBoltsCables/"+item_name).set_deferred("visible",false)
	get_node("NutsBoltsCables/"+item_name+"/PickupArea").set_deferred("disabled",true)
