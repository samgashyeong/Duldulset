extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var layout = Dialogic.start("res://Dialogue/Special/Sinyeoung/sinyeoung.dtl")
	var teemu_character = load("res://Dialogue/Char/TASinyeong.dch")
	var player_node = get_node(".") 
	var bubble_position = player_node.get_node("BubblePosition")
	layout.register_character(teemu_character, bubble_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
