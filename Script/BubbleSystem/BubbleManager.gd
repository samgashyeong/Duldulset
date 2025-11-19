# BubbleManager.gd
extends Node

@onready var bubbleText = preload("res://Scene/BubbleText/BubbleText.tscn")


func startDialog(position : Vector2, staff : Type.StaffName) -> Control:
	
	var dialogue_resource = staffNameCheck(staff)
	
	var new_textBox = bubbleText.instantiate()
	get_tree().root.add_child(new_textBox)
	new_textBox.setDialogueSource(dialogue_resource)
	new_textBox.global_position = position - Vector2(-90, 160) 
	
	return new_textBox
	
	
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
			push_error("Error: 정의되지 않은 StaffName입니다.", Type.StaffName)
			return null
			
	var loaded_resource = load(resource_path)
	return loaded_resource
