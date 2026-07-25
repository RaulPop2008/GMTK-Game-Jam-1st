extends Button

var glow_material: ShaderMaterial

func _ready():
	glow_material=material as ShaderMaterial
	mouse_entered.connect(on_hover)
	mouse_exited.connect(on_unhover)
	focus_entered.connect(on_hover)
	focus_exited.connect(on_unhover)
	glow_material.set_shader_parameter("glow_strength",0.0)

func on_hover():
	var tween=create_tween()
	tween.tween_method(set_glow_strength, get_glow_strength(),2.0,0.2)

func on_unhover():
	var tween=create_tween()
	tween.tween_method(set_glow_strength, get_glow_strength(),0.0,0.2)

func set_glow_strength(value: float):
	glow_material.set_shader_parameter("glow_strength",value)

func get_glow_strength() -> float:
	return glow_material.get_shader_parameter("glow_strength")
