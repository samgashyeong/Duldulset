#202221035현동우
extends Button 

const MAIN_SCENE_PATH = "res://Scene/MainGameScene2.tscn"

#게임시작(gamestart, go to main scene)
func _on_pressed():
	SoundManager.play_startclick_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
