# 202126868 Minseo Choi
extends TextureRect

var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
			z_index = 100
		else:
			dragging = false
			z_index = 0

	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() + drag_offset
