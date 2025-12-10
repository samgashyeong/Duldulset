class_name SugarButton extends Area2D

signal requested_sugar_spawn

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		GameData.sugar_count += 1
		SoundManager.play_Closebutton_sound()
		requested_sugar_spawn.emit()
		get_viewport().set_input_as_handled()
		
		#signal emit : junsang
		GameData.add_sugar.emit(GameData.sugar_count)
