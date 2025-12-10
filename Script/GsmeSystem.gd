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
const GAMEOVER_SCENE_PATH = "res://Scene/Screens/GameoverScene.tscn"

var current_stage_index = GameData.stage_level - 1

var game_logic

func _ready():
	game_logic = $GameLogic
	game_logic.stage_finished.connect(_on_game_logic_stage_finished)
	print("====[Stage Info]====")
	print("current stage: " + str(GameData.stage_level))
	print("====================")

func _process(_delta):
	#nextlevelscene나오는 타이밍
	if Input.is_action_just_pressed("Getnextscene"):
		go_to_next_scene()

func _on_game_logic_stage_finished(success: bool):
	if success:
		go_to_next_scene()
	else:
		go_to_gameover_scene()
		

func go_to_next_scene():
	#엔딩 호출
	if current_stage_index >= level_sequence.size():
		GameData.reset_stage_to_start()
		
		get_tree().paused = false
		SoundManager.play_Gameclear_sound()
		get_tree().change_scene_to_file(END_SCENE_PATH)
		return

	# 다음레벨
	# get_tree().paused = true
	
	var current_data = level_sequence[current_stage_index]
	var scene_path = current_data["scene"]
	var label_text = current_data["text"]
	
	var overlay_scene = load(scene_path)
	
	if overlay_scene:
		SoundManager.play_Tonext_sound()
		var next_stage_overlay = overlay_scene.instantiate()
		var label_node = next_stage_overlay.get_node_or_null("Textlabel/Tofixlabel")
		
		if label_node:
			label_node.text = label_text
			
		get_parent().add_child(next_stage_overlay)
		
		GameData.go_to_next_stage()

func go_to_gameover_scene():
	GameData.reset_stage_to_start()
	
	SoundManager.play_Gameover_sound()
	get_tree().change_scene_to_file(GAMEOVER_SCENE_PATH)
	
