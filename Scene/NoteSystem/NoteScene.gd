extends Control

@export var buttonGroup : ButtonGroup
@export var a : int

@export var type : Type.StaffName
@onready var animation = $AnimationPlayer
var staff : String
var staffScript : String
const ITEM = preload("res://Scene/NoteSystem/NoteElement.tscn")


func _ready() -> void:
	var buttons = buttonGroup.get_buttons()
	for button in buttons:
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed.bind(button))
	
	# 한 프레임 기다린 후 Junsang 버튼 선택
	await get_tree().process_frame
	staff = "Junsang"
	$HBoxContainer/VBoxContainer/Junsang.set_pressed(true)
	_on_button_pressed($HBoxContainer/VBoxContainer/Junsang)
	
	position = Vector2(320, 600)
	

func _on_button_pressed(button):
	
	var container = $HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer
	
	for i in range(2, 5):
		container.get_child(i).queue_free()
	match button.name:
		"Junsang":
			type = Type.StaffName.JUNSANG
			staff = "Junsang"
			staffScript = "I always like to play tricks on people"
	
		"Sangin":
			type = Type.StaffName.SANGIN
			staff = "Sangin"
			staffScript = "I think a little less coffee is better for the customer." # 예시 스크립트
	
		"Dongwoo":
			type = Type.StaffName.DONGWOO
			type = Type.StaffName.DONGWOO
			staff = "Dongwoo"
			staffScript = "My latte art is the best in the area." # 예시 스크립트
		
		"Minseo":
			type = Type.StaffName.MINSEO
			staff = "Minseo"
			staffScript = "I'm still learning the ropes, please bear with me." # 예시 스크립트
			
		"Oksoon":
			type = Type.StaffName.OKSOON
			staff = "Oksoon"
			staffScript = "A warm cup of tea is the best way to start the day." # 예시 스크립트
			
		"Younghee":
			type = Type.StaffName.YOUNGHEE
			staff = "Younghee"
			staffScript = "I love the smell of freshly roasted beans." # 예시 스크립트
	
		"Chunja":
			type = Type.StaffName.CHUNJA
			staff = "Chunja"
			staffScript = "It's a beautiful day to have a delicious americano." # 예시 스크립트
	
	makeListView(BubbleManager.staffNameCheck(type))
	
func makeListView(resoucre : Coffee):
	$HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer/Label.text = staff
	$HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer/Label2.text = staffScript
	
	for i in resoucre.orders:
		var container = $HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer
		
		var node = ITEM.instantiate()
		node.setData(i)
		container.add_child(node)
	
	
func pop_up():
	await get_tree().process_frame
	animation.play("pop up")
#


func _on_exit_button_pressed() -> void:
	await get_tree().process_frame
	animation.play("pop_down")	
