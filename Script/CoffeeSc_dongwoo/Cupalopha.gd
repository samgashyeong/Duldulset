extends TextureRect

func set_sprite_alpha(alpha_value: float):
  
	var current_color: Color = modulate
	current_color.a = alpha_value
	modulate = current_color

func _ready():
	set_sprite_alpha(0.5)
