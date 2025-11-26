extends Node

var level_sequence = [
	{
		"scene": "res://Scene/Screens/Nextstagescene1.tscn",
		"text": "Your Position :\nIntern -> Contract Worker"
	},
	{
		"scene": "res://Scene/Screens/Nextstagescene2.tscn",
		"text": "Your Position :\nContract Worker -> Junior Staff"
	},
	{
		"scene": "res://Scene/Screens/Nextstagescene1.tscn",
		"text": "Your Position :\nJunior staff -> Staff"
	},
	{
		"scene": "res://Scene/Screens/Nextstagescene2.tscn",
		"text": "Your Position :\nStaff -> Assistant Manager"
	}
]

const END_SCENE_PATH = "res://Scene/Screens/EndScene.tscn"

var current_stage_index = 0

func _process(_delta):
	if Input.is_action_just_pressed("Getnextscene"):
		go_to_next_scene()

func go_to_next_scene():
	#엔딩 호출
	if current_stage_index >= level_sequence.size():
		get_tree().paused = false
		get_tree().change_scene_to_file(END_SCENE_PATH)
		return

	# 다음레벨
	get_tree().paused = true
	
	var current_data = level_sequence[current_stage_index]
	var scene_path = current_data["scene"]
	var label_text = current_data["text"]
	
	var overlay_scene = load(scene_path)
	
	if overlay_scene:
		var next_stage_overlay = overlay_scene.instantiate()
		var label_node = next_stage_overlay.get_node_or_null("Textlabel/Tofixlabel")
		
		if label_node:
			label_node.text = label_text
			
		get_parent().add_child(next_stage_overlay)
		
		current_stage_index += 1
		
