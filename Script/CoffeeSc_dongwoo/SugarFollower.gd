class_name SugarFollower extends Area2D

signal placed(spawn_position)

func _ready():
	set_process(true)
	set_process_input(true)
	
func _process(_delta):
	global_position = get_global_mouse_position()
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		placed.emit(global_position)
		get_viewport().set_input_as_handled()
		set_process(false)
		set_process_input(false)
		queue_free()
