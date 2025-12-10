extends Button 

const Story_SCENE_PATH = "res://Scene/Screens/Storyscene.tscn"


func _on_pressed():
	SoundManager.play_startclick_sound()
	get_tree().change_scene_to_file(Story_SCENE_PATH)
