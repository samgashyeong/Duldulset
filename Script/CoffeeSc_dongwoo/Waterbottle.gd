class_name Waterbottle extends Area2D

signal picked_up

func lock():
	modulate = Color(1, 1, 1, 0.5) 
	set_process_input(false) 
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true

func unlock():
	modulate = Color(1, 1, 1, 1.0) 
	set_process_input(true) 
	if $CollisionShape2D:
		$CollisionShape2D.disabled = false


func hide_on_desk():
	visible = false
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		picked_up.emit()
		get_viewport().set_input_as_handled()
