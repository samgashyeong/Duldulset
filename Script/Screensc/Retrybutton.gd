extends Button 

const Retry_PATH = "res://Scene/Screens/Startscene.tscn"


func _on_pressed():
	get_tree().change_scene_to_file(Retry_PATH)
