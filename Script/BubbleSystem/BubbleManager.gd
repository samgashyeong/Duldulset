#202322158 이준상
extends Node

@onready var bubbleText = preload("res://Scene/BubbleText/BubbleText.tscn")


var bubbleContainer : Node




func _ready() -> void:
	bubbleContainer = Node.new()
	bubbleContainer.name = "BubbleContainer"
	get_tree().root.add_child(bubbleContainer)

func startDialog(position : Vector2, staff : Type.StaffName, target_npc : Node2D = null) -> Control:
	
	var dialogue_resource = staffNameCheck(staff)
	var new_textBox = bubbleText.instantiate()
	new_textBox.add_to_group("bubble")
	get_tree().root.add_child(new_textBox)
	new_textBox.setDialogueSource(dialogue_resource)
	new_textBox.global_position = position + Vector2(10, -55)
	
	new_textBox.z_index = 1000
	return new_textBox


func clearAllbubble():
	var bubbles_to_clear = get_tree().get_nodes_in_group("bubble")
	for bubble in bubbles_to_clear:
		bubble.queue_free()
	
	
func staffNameCheck(staff : Type.StaffName) -> Resource:
	var resource_path = ""
	match staff:
		Type.StaffName.JUNSANG:
			resource_path = "res://Script/Dialogue/Special/Coffee/Junsang/JunsangCoffee.tres"
			
		Type.StaffName.SANGIN:
			resource_path = "res://Script/Dialogue/Special/Coffee/Sangin/SanginCoffee.tres"
			
		Type.StaffName.MINSEO:
			resource_path = "res://Script/Dialogue/Special/Coffee/Minseo/MinseoCoffee.tres"
			
		Type.StaffName.DONGWOO:
			resource_path = "res://Script/Dialogue/Special/Coffee/Dongwoo/DongwooCoffee.tres"
			
		Type.StaffName.YOUNGHEE:
			resource_path = "res://Script/Dialogue/Special/Coffee/Younghee/YoungheeCoffee.tres"
			
		Type.StaffName.OKSOON:
			resource_path = "res://Script/Dialogue/Special/Coffee/Oksoon/OksoonCoffee.tres"
			
		Type.StaffName.CHUNJA:
			resource_path = "res://Script/Dialogue/Special/Coffee/Chunja/ChunjaCoffee.tres"
			
		_:
			push_error("Error", Type.StaffName)
			return null
			
	var loaded_resource = load(resource_path)
	return loaded_resource
