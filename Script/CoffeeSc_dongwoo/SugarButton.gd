#202221035 현동우
class_name SugarButton extends Area2D

# 설탕 생성을 요청하는 신호 (Signal to request sugar spawn)
signal requested_sugar_spawn

#클릭시설탕생성요청(Request sugar generation on click)
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		GameData.sugar_count += 1
		SoundManager.play_Closebutton_sound()
		requested_sugar_spawn.emit()
		# 입력 이벤트 처리 완료,중복방지 (Mark input event as handled,prevent duplication)
		get_viewport().set_input_as_handled()
