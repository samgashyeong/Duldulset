extends Node

func _process(delta: float) -> void:
	pass


func _on_game_timer_timeout() -> void:
	print("time out!")
	


func _on_game_timer_unit_time_passed() -> void:
	print("one game minute passed!")
