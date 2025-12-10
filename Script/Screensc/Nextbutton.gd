#202221035 현동우
extends Button 

const END_SCENE_PATH = "res://Scene/Screens/GameoverScene.tscn"

#nextlevelscene후제거다시게임시작(removing the next level scene, restart the game)
func _on_pressed():
	# 난이도 수정 코드(?)
	SoundManager.play_specialclick_sound()
	get_tree().paused = false
	owner.queue_free()
