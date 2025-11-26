extends VBoxContainer


const ITEM = preload("res://Scene/MenuSystem/MenuElement.tscn")
const CoffeeMenuClass = preload("res://Script/Dialogue/Special/Coffee/A_common/CoffeeMenu.gd")
var orderList : Array[CoffeeMenu]


func addMenu(menu : CoffeeMenu) : 
	
	var item_node = ITEM.instantiate()
	item_node.setData(menu)
	add_child(item_node)
	
	await get_tree().process_frame
	item_node.play_appear_animation()

func removeMenu(index: int) -> void:
	var target_node = get_child(index)
	
	await get_tree().process_frame
	target_node.play_disappear_animation()
	await get_tree().create_timer(1.5).timeout
	
	target_node.queue_free()

func _ready() -> void:
	
	var timer = get_tree().create_timer(0.5)
	
	await timer.timeout
	var coffeeTest = CoffeeMenuClass.new()
	
	coffeeTest.staff = "Junsang"
	coffeeTest.dialog = "fewfwef"
	addMenu(coffeeTest)
	timer = get_tree().create_timer(0.5)
	coffeeTest.dialog = "애국가 동해물과 백ㄷ수ㅏㄹㄷㅈㄹㅈㄷㅈㄷ"
	await timer.timeout
	addMenu(coffeeTest)
	timer = get_tree().create_timer(0.5)
	coffeeTest.dialog = "아아어ㅏㄹㄷ자러쟏러ㅑㅈ러쟈럳쟈러ㅑ"
	await timer.timeout
	addMenu(coffeeTest)
	
	
	await get_tree().create_timer(1.5).timeout
	removeMenu(2)
	#
	#await get_tree().create_timer(0.5).timeout
	#removeMenu()
