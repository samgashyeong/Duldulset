#202322158 이준상
# This file manages the element of menu


extends MarginContainer


# Variable to hold the data object (staff name and dialogue) for the order.
var order : CoffeeMenu

# Reference to the Label displaying the staff member's name.
@onready var staff = $MarginContainer/VBoxContainer/HBoxContainer/Label2
# Reference to the Label displaying the specific order dialogue.
@onready var orderDis = $MarginContainer/VBoxContainer/Label

func _ready():
	# Set the initial transparency to 0 (hidden) when the node is ready.
	modulate.a = 0.0

# Function to set the data for this menu element from a CoffeeMenu object.
func setData(menu : CoffeeMenu):
	# Re-assign @onready variables (redundant if using @onready, but kept for context).
	staff = $MarginContainer/VBoxContainer/HBoxContainer/Label2
	orderDis = $MarginContainer/VBoxContainer/Label
	# Store the data object.
	order = menu
	# Debug print statement for the staff name.
	print(menu.staff)
	# Update the staff name label.
	staff.text = menu.staff
	# Update the order dialogue label.
	orderDis.text = menu.dialog
	

# Starts the animation for the menu element to appear.
func play_appear_animation():
	# Get the AnimationPlayer node reference.
	var anim_player = $AnimationPlayer
	
	# Check if the AnimationPlayer exists.
	if anim_player:
		# Ensure the element is fully transparent before starting the appear animation.
		modulate.a = 0.0
		# Stop any currently playing animation.
		anim_player.stop()
		# Play the "new_animation" (appear) animation.
		anim_player.play("new_animation")
		

# Starts the animation for the menu element to disappear (fade out).
func play_disappear_animation():
	# Get the AnimationPlayer node reference.
	var anim_player = $AnimationPlayer
	
	# Ensure the element is fully opaque before starting the fade out.
	modulate.a = 1.0
	# Stop any currently playing animation.
	anim_player.stop()
	# Play the "fade_out" (disappear) animation.
	anim_player.play("fade_out")
