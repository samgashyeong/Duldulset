extends VBoxContainer


const ITEM = preload("res://Scene/MenuSystem/MenuElement.tscn")
const CoffeeMenuClass = preload("res://Script/Dialogue/Special/Coffee/A_common/CoffeeMenu.gd")
var orderList : Array[CoffeeMenu]


func addMenu(menu : CoffeeMenu) : 
	print("")
	
	var item_node = ITEM.instantiate()
	item_node.setData(menu)
	add_child(item_node)
	
	await get_tree().process_frame
	item_node.play_appear_animation()
	


func _ready() -> void:
	
	var timer = get_tree().create_timer(0.5)
	
	await timer.timeout
	var coffeeTest = CoffeeMenuClass.new()
	
	coffeeTest.staff = "Junsang"
	coffeeTest.dialog = "fewfwef"
	addMenu(coffeeTest)
	timer = get_tree().create_timer(0.5)
	await timer.timeout
	addMenu(coffeeTest)
	timer = get_tree().create_timer(0.5)
	await timer.timeout
	addMenu(coffeeTest)
