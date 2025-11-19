class_name SugarButton extends Area2D

signal requested_sugar_spawn

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		requested_sugar_spawn.emit()
		get_viewport().set_input_as_handled()
