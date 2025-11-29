extends Employee

func _ready():
	super()
	working_position = global_position
	staff_name = Type.StaffName.YOUNGHEE
	coffee_data = preload("res://Script/Dialogue/Special/Coffee/Younghee/YoungheeCoffee.tres")

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_interact = true


func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_interact = false
