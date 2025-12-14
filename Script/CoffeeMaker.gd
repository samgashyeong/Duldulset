# 202322111 임상인
# This script is for the coffee maker object on the map.

extends Node

var can_use_coffee_machine = false

signal coffee_making()

func _on_usable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_use_coffee_machine = true

func _on_usable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_use_coffee_machine = false


# This function handles the Player's interaction with the object.
func _input(event):
	if event.is_action_pressed("interact") and can_use_coffee_machine and !GameData.is_playing_minigame:
		print("interaction")
		GameData.is_playing_minigame = true
		coffee_making.emit()
