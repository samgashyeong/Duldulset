extends Control

@export var buttonGroup : ButtonGroup
@export var a : int

@export var type : Type.StaffName
@onready var animation = $AnimationPlayer
@onready var employee = $"../../NPC/Employee"
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
	
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		_employ.menu.connect(connectMenu)
		
	

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


func _on_exit_button_pressed() -> void:
	await get_tree().process_frame
	animation.play("pop_down")	

func connectMenu(type : Type.StaffMethod, name : Type.StaffName):
	var resource : Coffee = BubbleManager.staffNameCheck(name)
	print("menu test")
	match type:
		Type.StaffMethod.START0:
			resource.orders[0].isAction = true
		Type.StaffMethod.START1:
			resource.orders[1].isAction = true
		Type.StaffMethod.START2:
			resource.orders[2].isAction = true
		
	
	#var resource_path = resource.resource_path
	#if resource_path and resource_path.begins_with("res://"):
		#var error = ResourceSaver.save(resource, resource_path)
		#if error != OK:
			#print("Error saving resource: ", error)
		#else:
			#print("Resource successfully saved to: ", resource_path)
	
	#makeListView(resource)
