extends VBoxContainer


const ITEM = preload("res://Scene/MenuSystem/MenuElement.tscn")
const CoffeeMenuClass = preload("res://Script/Dialogue/Special/Coffee/A_common/CoffeeMenu.gd")
var orderList : Array[CoffeeMenu]
var menuList : Array[Type.StaffName]

@onready var employee = $"../../NPC/Employee"


func addMenu(menu : CoffeeMenu) : 
	var item_node = ITEM.instantiate()
	item_node.setData(menu)
	add_child(item_node)
	
	print("메뉴 리스트 " + str(menuList))
	await get_tree().process_frame
	item_node.play_appear_animation()

func removeMenu(index: int) -> void:
	menuList.remove_at(index)
	
	
	var target_node = get_child(index)
	
	await get_tree().process_frame
	target_node.play_disappear_animation()
	await get_tree().create_timer(1.5).timeout
	
	target_node.queue_free()

func _ready() -> void:
	
	var timer = get_tree().create_timer(0.5)
	
	await timer.timeout
	var coffeeTest = CoffeeMenuClass.new()
	
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		_employ.menu.connect(connectMenu)
		_employ.coffe_order_difference.connect(checkMenu)
		
	

func connectMenu(type : Type.StaffMethod, name : Type.StaffName):
	var resource : Coffee = BubbleManager.staffNameCheck(name)
	menuList.append(name)
	var order = ""
	match type:
		Type.StaffMethod.START0:
			order = resource.orders[0]
		Type.StaffMethod.START1:
			order = resource.orders[1]
		Type.StaffMethod.START2:
			order = resource.orders[2]
			
	var menu = CoffeeMenuClass.new()
	
	menu.staff = Type.StaffName.keys()[name]
	menu.dialog = order.dialog
	
	addMenu(menu)
	

func checkMenu(coffeeDiff:int, creamDiff:int, sugarDiff:int, staffName : Type.StaffName):
	
	var resource : Coffee = BubbleManager.staffNameCheck(staffName)
	for i in menuList.size():
		if menuList[i] == staffName:
			removeMenu(i)
			break;
	
			
		
