extends Node

var can_use_computer = false

signal using_computer()

@onready var task_list: DailyTask = $"../../../../GameSystem/TaskList"

func _on_usable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_use_computer = true


func _on_usable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_use_computer = false

func _input(event):
	if event.is_action_pressed("interact") and can_use_computer and !task_list.computer_task.is_empty() and !GameData.is_playing_minigame:
		print("interaction")
		GameData.is_playing_minigame = true
		using_computer.emit()
