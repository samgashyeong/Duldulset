# 202322111 임상인
# This script is for the NPC named 'Dongwoo'.

# Use 'Employee' class as superclass.
extends Employee

# This function initializes Dongwoo NPC.
func _ready():
	# initialize common things as Employee first
	super()
	
	# then initialize variables for specific Employee
	working_position = global_position
	staff_name = Type.StaffName.DONGWOO
	coffee_data = preload("res://Script/Dialogue/Special/Coffee/Dongwoo/DongwooCoffee.tres")


func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_interact = true

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_interact = false
