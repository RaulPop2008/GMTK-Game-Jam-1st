extends Control

signal dialogue_finished

@onready var label: RichTextLabel =$Panel/RichTextLabel

var dialogue_lines: Array[String] = [
	"After the explosion, the whole village has been wiped out",
	"Except myself at the cost of my left arm and my sanity",
	"If I stay too long here the radiation will age my organs and kill me",
	"I need to escape as soon as possible",
	"It's a battle against TIME!"
]
var current_line: int = 0
var is_typing: bool = false
var char_index: int = 0
var type_speed: float = 0.03

func _ready() -> void:
	start_line(current_line)

func start_line(index: int) -> void:
	label.text = dialogue_lines[index]
	label.visible_ratio = 0.0
	char_index = 0
	is_typing = true
	_type_text()

func _type_text() -> void:
	while is_typing and char_index <= dialogue_lines[current_line].length():
		label.visible_ratio = float(char_index) / dialogue_lines[current_line].length()
		char_index += 1
		await get_tree().create_timer(type_speed).timeout
	is_typing = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Esc implicit
		if is_typing:
			skip_typing()
		else:
			advance_line()
		get_viewport().set_input_as_handled()

func skip_typing() -> void:
	is_typing = false
	label.visible_ratio = 1.0

func end_dialogue() -> void:
	dialogue_finished.emit()
	queue_free()

func advance_line() -> void:
	current_line += 1
	if current_line < dialogue_lines.size():
		start_line(current_line)
	else:
		end_dialogue()
