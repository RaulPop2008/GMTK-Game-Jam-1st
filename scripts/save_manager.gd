extends Node

const SAVE_PATH_FORMAT := "user://savegame_%d.save"

var current_slot: int = 1

func get_save_path(slot: int) -> String:
	return SAVE_PATH_FORMAT % slot

func save_game(slot: int = current_slot) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("SaveManager: nu am gasit player-ul pentru save.")
		return

	var save_data := {
		"position_x": player.position.x,
		"position_y": player.position.y,

		"nuts": player.nuts,
		"bolts": player.bolts,
		"cables": player.cables,
		"batteries": player.batteries,

		"real_age": player.real_age,
		"internal_age": player.internal_age,

		"has_mask": player.has_mask,
		"has_suit": player.has_suit,
		"has_arm": player.has_arm,
		"has_leg": player.has_leg,

		"has_debuff_brain": player.has_debuff_brain,
		"has_debuff_leg": player.has_debuff_leg,
		"has_debuff_hand": player.has_debuff_hand,
		"has_debuff_vision": player.has_debuff_vision,
		"has_debuff_sleepy": player.has_debuff_sleepy,
		"has_debuff_breathing": player.has_debuff_breathing,
		"has_debuff_shaking": player.has_debuff_shaking,

		"debuff_brain_multiplier": player.debuff_brain_multiplier,
		"debuff_leg_multiplier": player.debuff_leg_multiplier,
		"debuff_hand_multiplier": player.debuff_hand_multiplier,
		"debuff_vision_multiplier": player.debuff_vision_multiplier,
		"debuff_sleepy_multiplier": player.debuff_sleepy_multiplier,
		"debuff_breathing_multiplier": player.debuff_breathing_multiplier,
		"debuff_shaking_multiplier": player.debuff_shaking_multiplier,

		"collected_items": player.collected_items,
	}

	var file := FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if not file:
		push_warning("SaveManager: nu am putut deschide fisierul pentru scriere. Eroare: " + str(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game(slot: int = current_slot) -> Dictionary:
	if not FileAccess.file_exists(get_save_path(slot)):
		return {}

	var file := FileAccess.open(get_save_path(slot), FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(content)
	if error != OK:
		push_warning("SaveManager: eroare la parsarea save-ului.")
		return {}

	return json.data

func apply_save_to_player(data: Dictionary) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or data.is_empty():
		return

	player.position = Vector2(data["position_x"], data["position_y"])

	player.nuts = data["nuts"]
	player.bolts = data["bolts"]
	player.cables = data["cables"]
	player.batteries = data["batteries"]

	player.real_age = data["real_age"]
	player.internal_age = data["internal_age"]

	player.has_mask = data["has_mask"]
	player.has_suit = data["has_suit"]
	player.has_arm = data["has_arm"]
	player.has_leg = data["has_leg"]

	player.has_debuff_brain = data["has_debuff_brain"]
	player.has_debuff_leg = data["has_debuff_leg"]
	player.has_debuff_hand = data["has_debuff_hand"]
	player.has_debuff_vision = data["has_debuff_vision"]
	player.has_debuff_sleepy = data["has_debuff_sleepy"]
	player.has_debuff_breathing = data["has_debuff_breathing"]
	player.has_debuff_shaking = data["has_debuff_shaking"]

	player.debuff_brain_multiplier = data["debuff_brain_multiplier"]
	player.debuff_leg_multiplier = data["debuff_leg_multiplier"]
	player.debuff_hand_multiplier = data["debuff_hand_multiplier"]
	player.debuff_vision_multiplier = data["debuff_vision_multiplier"]
	player.debuff_sleepy_multiplier = data["debuff_sleepy_multiplier"]
	player.debuff_breathing_multiplier = data["debuff_breathing_multiplier"]
	player.debuff_shaking_multiplier = data["debuff_shaking_multiplier"]

	var typed_collected_items: Array[String] = []
	for entry in data["collected_items"]:
		typed_collected_items.append(str(entry))
	player.collected_items = typed_collected_items

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))

func delete_save(slot: int) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(get_save_path(slot))

func get_save_preview(slot: int) -> Dictionary:
	if not has_save(slot):
		return {"has_save": false}
	var data = load_game(slot)
	if data.is_empty():
		return {"has_save": false}
	return {
		"has_save": true,
		"real_age": data.get("real_age", 0),
		"internal_age": data.get("internal_age", 0),
	}
