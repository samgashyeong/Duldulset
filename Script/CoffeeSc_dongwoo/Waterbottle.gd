#202221035 현동우
class_name Waterbottle extends Area2D

signal picked_up

# 물병을 사용 불가능 상태로 잠금 (Locks the bottle into an unusable state)
func lock():
	modulate = Color(1, 1, 1, 0.5) 
	set_process_input(false) 
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true

# 물병을 사용 가능 상태로 잠금 해제 (Unlocks the bottle to a usable state)
#Used in the main coffee scene. Waterbottle is activated only when coffee, sugar, or cream are added to the cup.
func unlock():
	modulate = Color(1, 1, 1, 1.0) 
	set_process_input(true) 
	if $CollisionShape2D:
		$CollisionShape2D.disabled = false

# 물병을 숨김 (Hide the water bottle)
func hide_on_desk():
	visible = false
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		picked_up.emit()
		SoundManager.play_Closebutton_sound()
		get_viewport().set_input_as_handled()
