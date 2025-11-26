extends Button 

const MAIN_SCENE_PATH = "res://Scene/MainGameScene.tscn"


func _on_pressed():
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
