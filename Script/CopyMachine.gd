extends Node

var can_use_copy_machine = false

signal using_copy_machine()

@onready var task_list: DailyTask = $"../../GameSystem/TaskList"

func _on_usable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		can_use_copy_machine = true

func _on_usable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_use_copy_machine = false

func _input(event):
	if event.is_action_pressed("interact") and can_use_copy_machine and task_list.copy_machine_task > 0 and !GameData.is_playing_minigame:
		print("interaction")
		GameData.is_playing_minigame = true
		using_copy_machine.emit()
