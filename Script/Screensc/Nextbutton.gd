#202221035 현동우
extends Button 

const NEXT_SCENE_PATH = "res://Scene/MainGameScene.tscn"


#nextlevelscene후제거다시게임시작(removing the next level scene, restart the game)
func _on_pressed():
	# 난이도 수정 코드(?)
	SoundManager.play_specialclick_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
	owner.queue_free()
