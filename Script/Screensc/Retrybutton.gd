extends Button 

const Retry_PATH = "res://Scene/Screens/Startscene.tscn"


func _on_pressed():
	SoundManager.play_specialclick_sound()
	get_tree().change_scene_to_file(Retry_PATH)
