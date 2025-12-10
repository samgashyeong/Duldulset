#202221035 현동우
class_name PrimButton extends Area2D

# 프림 생성을 요청하는 신호 (Signal to request prim spawn)
signal requested_prim_spawn(button_position)

#클릭시프림생성요청(Request prim generation on click)
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		GameData.prim_count += 1
		SoundManager.play_Closebutton_sound()
		requested_prim_spawn.emit(global_position)
		# 입력 이벤트 처리 완료,중복방지 (Mark input event as handled,prevent duplication)
		get_viewport().set_input_as_handled()
