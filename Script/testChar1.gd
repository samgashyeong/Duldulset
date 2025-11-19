extends Sprite2D

@export var playerType : Type.StaffName
var mouseEnter = false
var newbox = null
func _ready() -> void:
	var timer = get_tree().create_timer(3.0)


	await timer.timeout
	newbox = BubbleManager.startDialog(global_position, Type.StaffName.JUNSANG)
	newbox.textToDisPlay(Type.StaffMethod.ORDER)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inter_action") and mouseEnter:
		##여기에 원래 interActionWithPlayer를 호출하려고 했지만 싱글톤 패턴때문에 고민중임
		print("asdf")
		newbox.textToDisPlay(Type.StaffMethod.START0)


func _on_area_2d_2_mouse_entered() -> void:
	mouseEnter = true


func _on_area_2d_2_mouse_exited() -> void:
	mouseEnter = false
