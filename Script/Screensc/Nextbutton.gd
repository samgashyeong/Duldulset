extends Button 

const NEXT_SCENE_PATH = "res://Scene/MainGameScene.tscn"


func _on_pressed():
	# 난이도 수정 코드(?)
	SoundManager.play_specialclick_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
	owner.queue_free()
