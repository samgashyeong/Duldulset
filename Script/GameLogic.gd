extends Node

var wandering_probability = 0.1
var coffee_order_probability = 0.3
var employees

@onready var map: TileMapLayer = $"../../Map/WalkableArea"

func _ready():
	employees = get_tree().get_nodes_in_group("employees")
	
func _process(delta: float) -> void:
	if GameData.is_playing_minigame:
		GameData.main_time_scale = 0.5
	else:
		GameData.main_time_scale = 1.0


func _on_game_timer_timeout() -> void:
	print("time out!")
	get_tree().paused = true
	


func _on_game_timer_unit_time_passed() -> void:
	print("one game minute passed!")
	
	if randf() < wandering_probability:
		var candidates = []
		for employee in employees:
			if employee.state == Employee.States.SITTING:
				candidates.append(employee)
		if !candidates.is_empty():
			var random_tile_position = Vector2i(randi_range(2, 13), randi_range(1, 10))
			var random_position = map.map_to_local(random_tile_position)
			candidates.pick_random().wander(random_position)
	
	if randf() < coffee_order_probability:
		var candidates = []
		for employee in employees:
			if employee.state == Employee.States.SITTING:
				candidates.append(employee)
		if !candidates.is_empty():
			candidates.pick_random().order_coffee()
