extends Sprite2D

@export var playerType : Type.StaffName

var mouseEnter = false
var newbox
func _ready() -> void:
	var timer = get_tree().create_timer(2.0)


	await timer.timeout
	newbox = BubbleManager.startDialog(global_position, Type.StaffName.JUNSANG)
	newbox.textToDisPlay(Type.StaffMethod.ORDER)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inter_action") and mouseEnter:
		print("fffasdf")
		newbox.textToDisPlay(Type.StaffMethod.START1)


func _on_area_2d_mouse_entered() -> void:
	mouseEnter = true
	print(mouseEnter)




func _on_area_2d_mouse_exited() -> void:
	mouseEnter = false
	print(mouseEnter)
