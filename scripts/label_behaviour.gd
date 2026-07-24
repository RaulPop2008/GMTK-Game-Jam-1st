extends Label

@export var glow_strength_value: float = 2.0

func _ready():
	var green=Color(0.514, 1.0, 0.6)
	add_theme_color_override("font_color",green)
	material = material.duplicate()
	var glow_material := material as ShaderMaterial
	if glow_material:
		glow_material.set_shader_parameter("glow_strength", glow_strength_value)
