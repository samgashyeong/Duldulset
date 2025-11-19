class_name PrimButton extends Area2D

signal requested_prim_spawn(button_position)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		requested_prim_spawn.emit(global_position)
		get_viewport().set_input_as_handled()
