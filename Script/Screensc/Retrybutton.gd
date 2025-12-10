#202221035현동우
extends Button 

const Retry_PATH = "res://Scene/Screens/Startscene.tscn"

#다시시작화면으로(return to start screen)
func _on_pressed():
	SoundManager.play_specialclick_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file(Retry_PATH)
