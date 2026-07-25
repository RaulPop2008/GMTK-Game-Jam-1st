extends Label

@export var glow_strength_value: float = 2.0
const font_size_selection:int=20
const font_material:FontFile=preload("res://fonts/BlackOpsOne-Regular.ttf")

func _ready():
	add_theme_font_size_override("font_size",font_size_selection)
	add_theme_font_override("font",font_material)
