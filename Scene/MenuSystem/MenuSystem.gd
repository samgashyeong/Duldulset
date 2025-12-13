#202322158 이준상
# This file manages the dynamic menu list UI, adding and removing order elements as NPCs request coffee.


extends VBoxContainer


# Preloads the scene for a single menu item element.
const ITEM = preload("res://Scene/MenuSystem/MenuElement.tscn")
# Preloads the CoffeeMenu class script for instancing menu data objects.
const CoffeeMenuClass = preload("res://Script/Dialogue/Special/Coffee/A_common/CoffeeMenu.gd")
# Array to hold CoffeeMenu objects (currently appears unused or merged with menuList concept).
var orderList : Array[CoffeeMenu]
# Array to hold staff names (Type.StaffName enum values) corresponding to current orders displayed in the UI.
var menuList : Array[Type.StaffName]

# Reference to the NPC/Employee node, accessed from the scene root.
@onready var employee = $"../../NPC/Employee"


# Function to add a new menu item to the container.
func addMenu(menu : CoffeeMenu) :
	# Instantiate a new menu item node from the preloaded scene.
	var item_node = ITEM.instantiate()
	# Set the data (staff name and dialog) for the new menu item UI element.
	item_node.setData(menu)
	# Add the menu item node as a child of this VBoxContainer.
	add_child(item_node)
	
	# Debug print statement showing the current list of staff names waiting for orders.
	print("메뉴 리스트 " + str(menuList))
	# Wait for the next physics frame to ensure the node is initialized and ready for animation.
	await get_tree().process_frame
	# Play the animation for the menu item appearing.
	item_node.play_appear_animation()

# Function to remove a menu item from the container and the list by index.
func removeMenu(index: int) -> void:
	# Removes the staff name from the list of active orders at the specified index.
	menuList.remove_at(index)
	# Debug print statement showing the index that was removed.
	print("removeMenu : " + str(index))
	
	# Get the child node at the specified index (which is the MenuElement node).
	var target_node = get_child(index)
	
	# Wait for the next physics frame.
	await get_tree().process_frame
	# Play the animation for the menu item disappearing.
	target_node.play_disappear_animation()
	# Wait for 1.5 seconds to allow the disappearance animation to fully finish.
	await get_tree().create_timer(1.5).timeout
	
	# Safely delete the node from memory after the animation completes.
	target_node.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Create a timer that waits for 0.5 seconds (initial delay).
	var timer = get_tree().create_timer(0.5)
	
	# Wait for the initial delay to finish.
	await timer.timeout
	# Instantiate a test CoffeeMenu object (currently unused).
	var coffeeTest = CoffeeMenuClass.new()
	
	# Loop through all children of the 'employee' node (assuming each child is an NPC/staff).
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		# Connect the 'menu' signal (new order request) from the employee to the connectMenu function.
		_employ.menu.connect(connectMenu)
		# Connect the 'coffe_order_difference' signal (order check/completion) to the checkMenu function.
		_employ.coffe_order_difference.connect(checkMenu)
		
	

# Handler function called when an employee signals a new menu/order.
func connectMenu(type : Type.StaffMethod, name : Type.StaffName):
	# Get the coffee resource data associated with the staff name using a manager utility.
	var resource : Coffee = BubbleManager.staffNameCheck(name)
	# Add the staff name to the list of active orders.
	menuList.append(name)
	var order = ""
	# Determine which specific order string to use based on the StaffMethod type.
	match type:
		Type.StaffMethod.START0:
			order = resource.orders[0]
		Type.StaffMethod.START1:
			order = resource.orders[1]
		Type.StaffMethod.START2:
			order = resource.orders[2]
			
	# Create a new CoffeeMenu object to hold the order data for the UI.
	var menu = CoffeeMenuClass.new()
	
	# Set the staff name using the key string of the enum value for display.
	menu.staff = Type.StaffName.keys()[name]
	# Set the dialogue string for the menu item from the chosen order.
	menu.dialog = order.dialog
	
	# Add the newly created menu item to the container UI.
	addMenu(menu)
	

# Handler function called when an employee's order is checked (i.e., when an order is completed).
func checkMenu(coffeeDiff:int, creamDiff:int, sugarDiff:int, staffName : Type.StaffName, orderType : int):
	# Get the coffee resource data (currently unused in this function body).
	var resource : Coffee = BubbleManager.staffNameCheck(staffName)
	# Iterate through the active menu list to find the completed order's staff name.
	for i in menuList.size():
		if menuList[i] == staffName:
			# If the staff name matches an active order, remove the corresponding UI element.
			removeMenu(i)
			# Exit the loop once the matching order is found and removed.
			break;
