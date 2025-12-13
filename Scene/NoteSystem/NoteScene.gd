#202322158 이준상
# This file manages the "Note System" UI, allowing the player to view staff profiles and their coffee ratio information.


extends Control

# Export variable to group staff selection buttons.
@export var buttonGroup : ButtonGroup
# Export variable 'a' (placeholder or unused).
@export var a : int

# Export variable to hold the currently selected staff member's enum type.
@export var type : Type.StaffName
# Reference to the AnimationPlayer node.
@onready var animation = $AnimationPlayer
# Reference to the NPC/Employee container node.
@onready var employee = $"../../NPC/Employee"
# Flag indicating if the dialog/note panel is currently popped up (visible).
@onready var dialogUp = false
# Flag indicating if the dialog/note panel is currently popped down (hidden).
@onready var dialogDown = true
# String to store the currently selected staff member's name.
var staff : String
# String to store the currently selected staff member's script/description.
var staffScript : String
# Preloads the scene for a single note element (order detail).
const ITEM = preload("res://Scene/NoteSystem/NoteElement.tscn")


# Flag used during initial setup to prevent sound effects/unintended actions.
var is_initializing : bool = true

func _ready() -> void:
	# Get all buttons in the ButtonGroup.
	var buttons = buttonGroup.get_buttons()
	# Connect the '_on_button_pressed' function to each button's 'pressed' signal.
	for button in buttons:
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed.bind(button))
	
	
	# Wait for the next process frame.
	await get_tree().process_frame
	# Set the default selected staff member to "Junsang".
	staff = "Junsang"
	# Programmatically press the "Junsang" button to set initial state.
	$HBoxContainer/VBoxContainer/Junsang.set_pressed(true)
	# Manually call the handler for the initial button press.
	_on_button_pressed($HBoxContainer/VBoxContainer/Junsang)
	
	# Finish initialization.
	is_initializing = false
	
	# Set the initial position of the control (likely off-screen or centered).
	position = Vector2(320, 600)
	
	# Connect signals from all employee NPCs.
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		# Connect 'menu' (new order request) signal to connectMenu.
		_employ.menu.connect(connectMenu)
		# Connect 'coffe_order_difference' (order completion check) signal to checkCoffee.
		_employ.coffe_order_difference.connect(checkCoffee)
		
	

# Handler for staff selection buttons being pressed.
func _on_button_pressed(button):
	
	# Play sound if not during initialization.
	if not is_initializing:
		SoundManager.play_Smallclick_sound()
	
	# Get the container for the staff's order details.
	var container = $HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer
	
	# Clear previous order notes (children 2, 3, 4 which are the note elements).
	for i in range(2, 5):
		container.get_child(i).queue_free()
		
	# Update the selected staff based on the button name.
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
	
	# Generate and display the list of orders for the newly selected staff.
	makeListView(BubbleManager.staffNameCheck(type))
	
# Populates the list view with staff details and their coffee orders.
func makeListView(resoucre : Coffee):
	# Update the staff name label.
	$HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer/Label.text = staff
	# Update the staff description label.
	$HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer/Label2.text = staffScript
	
	# Iterate through all saved orders for the staff.
	for i in resoucre.orders:
		var container = $HBoxContainer/Sprite2D/ScrollContainer/VBoxContainer
		
		# Instantiate a new NoteElement node.
		var node = ITEM.instantiate()
		# Set the data for the note element (order details).
		node.setData(i)
		# Add the note element to the list container.
		container.add_child(node)
	
	
# Animates the note panel to pop up (appear).
func pop_up():
	# Play the pop-up sound effect.
	SoundManager.play_Noteflip_sound()
	# Wait for the next process frame.
	await get_tree().process_frame
	# Check if the dialog is not already up.
	if !dialogUp:
		# Play the pop-up animation.
		animation.play("pop up")
		# Wait for the animation to finish.
		await animation.animation_finished
		# Set the flag to indicate the dialog is up.
		dialogUp = true


# Handler for the exit button being pressed.
func _on_exit_button_pressed() -> void:
	# Play the close button sound effect.
	SoundManager.play_Closebutton_sound()
	# Wait for the next process frame.
	await get_tree().process_frame
	# Check if the dialog is currently up.
	if dialogUp:
		# Play the pop-down animation.
		animation.play("pop_down")
		# Wait for the animation to finish.
		await animation.animation_finished
		# Set the flag to indicate the dialog is down.
		dialogUp = false


# Handles the signal when a staff member makes a new coffee order.
func connectMenu(type : Type.StaffMethod, name : Type.StaffName):
	# Get the coffee resource data for the staff member.
	var resource : Coffee = BubbleManager.staffNameCheck(name)
	# Debug print.
	print("menu test")
	# Set the 'isAction' flag to true for the specific order that was just made.
	match type:
		Type.StaffMethod.START0:
			resource.orders[0].isAction = true
		Type.StaffMethod.START1:
			resource.orders[1].isAction = true
		Type.StaffMethod.START2:
			resource.orders[2].isAction = true
		


# Handles the signal when an attempted coffee order is checked against the staff's preference.
func checkCoffee(coffee_diff: int, cream_diff: int, sugar_diff: int, staffName : Type.StaffName, orderType: int):
	# Get the coffee resource data for the staff member.
	var resource : Coffee = BubbleManager.staffNameCheck(staffName)

	# If the coffee amount difference is zero (match), mark the coffee requirement as cleared.
	if(coffee_diff == 0):
		resource.orders[orderType].isCoffeeClear = true
		
	# If the cream amount difference is zero (match), mark the cream requirement as cleared.
	if(cream_diff==0):
		resource.orders[orderType].isCreamClear = true
	
	# If the sugar amount difference is zero (match), mark the sugar requirement as cleared.
	if(sugar_diff == 0):
		resource.orders[orderType].isSugarClear = true
