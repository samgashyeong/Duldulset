#202221035현동우
extends Button 

const Story_SCENE_PATH = "res://Scene/Screens/Storyscene.tscn"

#스토리시작(start story scene)
func _on_pressed():
	SoundManager.play_startclick_sound()
	get_tree().change_scene_to_file(Story_SCENE_PATH)
