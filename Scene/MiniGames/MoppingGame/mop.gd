# 202126868 Minseo Choi
extends TextureRect

var is_dragging: bool = false
var drag_offset_from_mouse: Vector2 = Vector2.ZERO
var start_position: Vector2

func _ready() -> void:
	# Allow this control to receive mouse events and ignore keyboard focus
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	start_position = global_position


# Handle mouse press / release / move to implement drag
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start dragging: remember offset so the icon does not snap to cursor center
			is_dragging = true

			SoundManager.play_startclick_sound()

			drag_offset_from_mouse = global_position - get_global_mouse_position()
			z_index = 100  # Bring icon to front while dragging
		else:
			# Mouse released: stop dragging and restore z_index
			is_dragging = false
			global_position = start_position

	elif event is InputEventMouseMotion and is_dragging:
		# While dragging, follow the mouse while preserving initial offset
		global_position = get_global_mouse_position() + drag_offset_from_mouse
