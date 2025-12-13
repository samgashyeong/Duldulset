#202221035현동우
extends Node2D

# 게임 시작 시 표시할 대화 텍스트 배열 (Array of dialogue texts to display at the start)
var dialogues = [
	"My name is Gilyoung, born in 1965, and this year I am 24 years old and a fully-fledged member of society.",
	"After years of effort, I finally got accepted into CMP, the company I had always dreamed of.",
	"A friend who joined the company earlier told me that the essential virtue for an intern is DulDulSet.",
	"DulDulSet. Coffee 2, Prim 2, Sugar 3.",
	"Okay, it's perfect. All preparations are complete. Come on, bring it on, company!"
]

var current_line_index = 0 
const MAIN_SCENE_PATH = "res://Scene/MainGameScene.tscn"

var is_typing = false
var current_tween: Tween

@onready var story_text_label = $UI_Layer/DialogueBox/StoryText
@onready var next_button = $UI_Layer/DialogueBox/Nextbutton

# 초기화 및 첫 줄 표시 (Initialization and display the first line)
func _ready():
	show_current_line()
	next_button.pressed.connect(_on_next_button_pressed)

# 텍스트 출력 및 타이핑 애니메이션 실행 (Display text and run typing animation)
func show_current_line():
	if current_line_index < dialogues.size():
		story_text_label.text = dialogues[current_line_index]
		story_text_label.visible_ratio = 0.0
		is_typing = true
		var duration = story_text_label.text.length() * 0.05
		
		current_tween = create_tween()
		current_tween.tween_property(story_text_label, "visible_ratio", 1.0, duration)
		
		current_tween.finished.connect(_on_typing_finished)
		
	else:
		finish_story() # 모든 대화 완료, 씬 전환 (All dialogues finished, change scene)

func _on_typing_finished():
	is_typing = false

func _on_next_button_pressed():
	# 타이핑 중이면 즉시 완료 처리 (If typing, instantly complete it)
	if is_typing:
		if current_tween:
			current_tween.kill()
		story_text_label.visible_ratio = 1.0
		is_typing = false
	# 완료 후 클릭 시 다음 대화로 이동 (If finished, move to the next dialogue)
	else:
		current_line_index += 1
		show_current_line()
		
# 메인 게임 씬으로 전환 (Change to Main Game Scene)
func finish_story():
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

# 버튼 클릭 사운드 재생 (Play button click sound)
func _on_nextbutton_pressed():
	SoundManager.play_Storynext_sound()
