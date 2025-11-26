extends Node

var can_use_computer = false

signal using_computer()

func _on_usable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_use_computer = true


func _on_usable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_use_computer = false

func _input(event):
	if event.is_action_pressed("interact") and can_use_computer and !GameData.is_playing_minigame:
		print("interaction")
		GameData.is_playing_minigame = true
		using_computer.emit()
