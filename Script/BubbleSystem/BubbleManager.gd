#202322158 이준상
# This file serves as a Singleton for handling NPC speech bubbles and dialogue resources.


extends Node

# Preloads the scene for the BubbleText UI element.
@onready var bubbleText = preload("res://Scene/BubbleText/BubbleText.tscn")


# Node to serve as a container for all active speech bubbles (although unused in current implementation).
var bubbleContainer : Node




func _ready() -> void:
	# Create a new Node instance to act as a container.
	bubbleContainer = Node.new()
	# Set the name of the container node.
	bubbleContainer.name = "BubbleContainer"
	# Add the container node to the root of the scene tree (unmanaged by the BubbleManager itself).
	get_tree().root.add_child(bubbleContainer)

# Instantiates a new speech bubble and starts the dialogue process.
func startDialog(position : Vector2, staff : Type.StaffName, target_npc : Node2D = null) -> Control:
	
	# Get the correct dialogue resource file for the specified staff member.
	var dialogue_resource = staffNameCheck(staff)
	# Instantiate a new bubble text scene.
	var new_textBox = bubbleText.instantiate()
	# Add the new bubble to a group for easy global access and clearing.
	new_textBox.add_to_group("bubble")
	# Add the new bubble directly to the root of the scene tree.
	get_tree().root.add_child(new_textBox)
	# Assign the loaded dialogue resource to the bubble instance.
	new_textBox.setDialogueSource(dialogue_resource)
	# Set the initial global position of the bubble with a slight offset.
	new_textBox.global_position = position + Vector2(10, -55)
	
	# Ensure the bubble is rendered on top of other elements.
	new_textBox.z_index = 1000
	# Return the new bubble instance.
	return new_textBox


# Finds and deletes all active speech bubbles in the scene.
func clearAllbubble():
	# Get all nodes currently in the "bubble" group.
	var bubbles_to_clear = get_tree().get_nodes_in_group("bubble")
	# Iterate through the list and safely delete each bubble.
	for bubble in bubbles_to_clear:
		bubble.queue_free()
	
	
# Looks up and loads the specific Coffee resource file based on the staff's name.
func staffNameCheck(staff : Type.StaffName) -> Resource:
	var resource_path = ""
	# Match the staff enum to the corresponding resource file path.
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
			
		# Handle unexpected staff names by logging an error and returning null.
		_:
			push_error("Error", Type.StaffName)
			return null
			
	# Load the resource from the determined path.
	var loaded_resource = load(resource_path)
	return loaded_resource
