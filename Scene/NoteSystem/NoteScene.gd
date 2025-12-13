#202322158 이준상

extends Control

@export var buttonGroup : ButtonGroup
@export var a : int

@export var type : Type.StaffName
@onready var animation = $AnimationPlayer
@onready var employee = $"../../NPC/Employee"
@onready var dialogUp = false
@onready var dialogDown = true
var staff : String
var staffScript : String
const ITEM = preload("res://Scene/NoteSystem/NoteElement.tscn")


var is_initializing : bool = true

func _ready() -> void:
	var buttons = buttonGroup.get_buttons()
	for button in buttons:
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed.bind(button))
	
	
	await get_tree().process_frame
	staff = "Junsang"
	$HBoxContainer/VBoxContainer/Junsang.set_pressed(true)
	_on_button_pressed($HBoxContainer/VBoxContainer/Junsang)
	
	is_initializing = false
	
	position = Vector2(320, 600)
	
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		_employ.menu.connect(connectMenu)
		_employ.coffe_order_difference.connect(checkCoffee)
		
	

func _on_button_pressed(button):
	
	if not is_initializing:
		SoundManager.play_Smallclick_sound()
	
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
			staffScript = "More Sugar!!"
	
		"Dongwoo":
			type = Type.StaffName.DONGWOO
			staff = "Dongwoo"
			staffScript = "Hi! I love game..I don't know what is Cream..."
		
		"Minseo":
			type = Type.StaffName.MINSEO
			staff = "Minseo"
			staffScript = "EXTREME."
			
		"Oksoon":
			type = Type.StaffName.OKSOON
			staff = "Oksoon"
			staffScript = "Hello, I hate coffee...."
			
		"Younghee":
			type = Type.StaffName.YOUNGHEE
			staff = "Younghee"
			staffScript = "Hello! I love cream!!"
		"Chunja":
			type = Type.StaffName.CHUNJA
			staff = "Chunja"
			staffScript = "I really don't like you and I hate sugar..." 
	
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
	SoundManager.play_Noteflip_sound()
	await get_tree().process_frame
	if !dialogUp:
		animation.play("pop up")
		await animation.animation_finished
		dialogUp = true


func _on_exit_button_pressed() -> void:
	SoundManager.play_Closebutton_sound()
	await get_tree().process_frame
	if dialogUp:
		animation.play("pop_down")
		await animation.animation_finished
		dialogUp = false


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

func checkCoffee(coffee_diff: int, cream_diff: int, sugar_diff: int, staffName : Type.StaffName, orderType: int):
	var resource : Coffee = BubbleManager.staffNameCheck(staffName)

	if(coffee_diff == 0):
		resource.orders[orderType].isCoffeeClear = true
		
	if(cream_diff==0):
		resource.orders[orderType].isCreamClear = true
	
	if(sugar_diff == 0):
		resource.orders[orderType].isSugarClear = true
