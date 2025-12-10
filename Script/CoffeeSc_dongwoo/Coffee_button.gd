#202221035 현동우
class_name CoffeeButton extends Area2D

# 커피콩 생성을 요청하는 신호 (Signal to request coffee bean spawn)
signal requested_coffeebean_spawn(button_position)

#클릭시커피생성요청(Request coffeebean generation on click)
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		GameData.coffee_count += 1
		SoundManager.play_Closebutton_sound()
		requested_coffeebean_spawn.emit(global_position)
		# 입력 이벤트 처리 완료,중복방지 (Mark input event as handled,prevent duplication)
		get_viewport().set_input_as_handled()
		
		#emit signal : junsang
		GameData.add_coffee.emit(GameData.coffee_count)
