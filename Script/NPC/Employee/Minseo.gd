# 202322111 임상인
# This script is for the NPC named 'Minseo'.

# Use 'Employee' class as superclass.
extends Employee

# This function initializes Minseo NPC.
func _ready():
	# initialize common things as Employee first
	super()
	
	# then initialize variables for specific Employee
	working_position = global_position
	staff_name = Type.StaffName.MINSEO
	coffee_data = preload("res://Script/Dialogue/Special/Coffee/Minseo/MinseoCoffee.tres")


func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_interact = true

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_interact = false
