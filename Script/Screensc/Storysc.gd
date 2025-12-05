extends Node2D

var dialogues = [
	"My name is Gilyoung, born in 1965, and this year I am 24 years old and a fully-fledged member of society.",
	"After years of effort, I finally got accepted into CMP, the company I had always dreamed of.",
	"A friend who joined the company earlier told me that the essential virtue for an intern is DulDulSet.",
	"DulDulSet. Coffee 2, Prim 2, Sugar 3.",
	"Okay, it's perfect. All preparations are complete. Come on, bring it on, company!"
]

var current_line_index = 0 
const MAIN_SCENE_PATH = "res://Scene/MainGameScene2.tscn"

var is_typing = false
var current_tween: Tween

@onready var story_text_label = $UI_Layer/DialogueBox/StoryText
@onready var next_button = $UI_Layer/DialogueBox/Nextbutton

func _ready():
	show_current_line()
	next_button.pressed.connect(_on_next_button_pressed)

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
		finish_story()

func _on_typing_finished():
	is_typing = false

func _on_next_button_pressed():
	if is_typing:
		if current_tween:
			current_tween.kill()
		story_text_label.visible_ratio = 1.0
		is_typing = false
		
	else:
		current_line_index += 1
		show_current_line()

func finish_story():
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_nextbutton_pressed():
	SoundManager.play_Storynext_sound()
