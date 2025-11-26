extends Button 

func _on_pressed():
	# 난이도 수정 코드(?)
	get_tree().paused = false
	owner.queue_free()
