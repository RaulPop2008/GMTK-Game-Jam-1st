extends Button

var font_size_selection=36
var base_text:String
var glow_material: ShaderMaterial
var font_material:FontFile=preload("res://fonts/SpecialElite-Regular.ttf")

func _ready():
	base_text=text
	glow_material=material as ShaderMaterial
	var green=Color(0.514, 1.0, 0.6, 1.0)
	add_theme_color_override("font_color",green)
	add_theme_color_override("font_hover_color",green)
	add_theme_color_override("font_focus_color",green)
	add_theme_color_override("font_pressed_color",green)
	add_theme_font_size_override("font_size",font_size_selection)
	add_theme_font_override("font",font_material)
	mouse_entered.connect(on_hover)
	mouse_exited.connect(on_unhover)
	focus_entered.connect(on_hover)
	focus_exited.connect(on_unhover)
	glow_material.set_shader_parameter("glow_strength",0.0)

func on_hover():
	text="[  "+base_text+"  ]"
	var tween=create_tween()
	tween.tween_method(set_glow_strength, get_glow_strength(),2.0,0.2)

func on_unhover():
	text=base_text
	var tween=create_tween()
	tween.tween_method(set_glow_strength, get_glow_strength(),0.0,0.2)

func set_glow_strength(value: float):
	glow_material.set_shader_parameter("glow_strength",value)

func get_glow_strength() -> float:
	return glow_material.get_shader_parameter("glow_strength")
