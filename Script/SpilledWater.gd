extends Node2D

var can_cleanup = false

signal water_cleaning()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		can_cleanup = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		can_cleanup = false

func _input(event):
	if event.is_action_pressed("interact") and can_cleanup and !GameData.is_playing_minigame:
		print("interaction")
		GameData.is_playing_minigame = true
		water_cleaning.emit()

func cleanup():
	if can_cleanup:
		print("cleanup spilled water")
		queue_free()
