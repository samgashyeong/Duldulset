#202221035현동우
extends Node

# 게임 스테이지 진행 순서 및 정보 배열 (Array defining game stage progression and data)
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

# 특정 입력 시 다음 씬으로 전환 (Transition to next scene on specific input)
func _process(_delta):
	if Input.is_action_just_pressed("Getnextscene"):
		go_to_next_scene()

# 다음 레벨 오버레이를 띄우거나 최종 엔딩으로 전환 (Display next level overlay or transition to final ending)
func go_to_next_scene():
	# 모든 스테이지 완료 시 엔딩 씬 로드 (Load End Scene if all stages are complete)
	if current_stage_index >= level_sequence.size():
		get_tree().paused = false
		SoundManager.play_Gameclear_sound()
		get_tree().change_scene_to_file(END_SCENE_PATH)
		return

	# 다음 레벨 화면을 로드하여 일시 정지 상태로 표시 (Load and display the next level screen while pausing the game)
	get_tree().paused = true
	
	var current_data = level_sequence[current_stage_index]
	var scene_path = current_data["scene"]
	var label_text = current_data["text"]
	
	var overlay_scene = load(scene_path)
	
	if overlay_scene:
		SoundManager.play_Tonext_sound()
		var next_stage_overlay = overlay_scene.instantiate()
		var label_node = next_stage_overlay.get_node_or_null("Textlabel/Tofixlabel")
		
		if label_node:
			# 오버레이에 다음 직급 텍스트 삽입 (Insert next position text into the overlay)
			label_node.text = label_text
			
		get_parent().add_child(next_stage_overlay)
		
		current_stage_index += 1
		
