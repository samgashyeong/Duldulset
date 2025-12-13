#202221035 현동우
class_name SugarFollower extends Area2D

# 배치 위치를 알리는 신호 (Signal to announce placement position)
signal placed(spawn_position)

func _ready():
	set_process(true)
	set_process_input(true)
	
func _process(_delta):
	# 마우스 위치를 따라 이동 (Follow the global mouse position)
	global_position = get_global_mouse_position()
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# 배치 완료 신호 발사 (Emit placement signal)
		placed.emit(global_position)
		get_viewport().set_input_as_handled()
		set_process(false)
		set_process_input(false)
		queue_free()
