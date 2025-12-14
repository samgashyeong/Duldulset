# 202322111 임상인
# This script is for the spilled water object on the map.

extends Node2D

var can_cleanup = false

signal water_cleaning()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		can_cleanup = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		can_cleanup = false


# This function handles the Player's interaction with the object.
func _input(event):
	if event.is_action_pressed("interact") and can_cleanup and !GameData.is_playing_minigame:
		print("interaction")
		GameData.is_playing_minigame = true
		water_cleaning.emit()


# This function handles the case when the spilled water itself should be cleaned up.
func cleanup():
	if can_cleanup:
		print("cleanup spilled water")
		remove_from_group("spilled_waters")
		queue_free()
