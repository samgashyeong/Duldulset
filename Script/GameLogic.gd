extends Node

var wandering_probability = 0.1 #0.2 #0.1 #0.05
var coffee_order_probability = 0.03 #0.05 #0.0 #0.05 #0.1
var employees

var water_spill_probability = 0.01

var game_hour: int = 9

@onready var map: TileMapLayer = $"../../Map/WalkableArea"

var special_event_resource_paths = [
	"res://Scene/NPC/Special/Teemu.tscn",
	"res://Scene/NPC/Special/TASinyeong.tscn",
	"res://Scene/NPC/Special/Jensen.tscn",
	"res://Scene/NPC/Special/Boss.tscn"
	]

var special_character_scene: PackedScene = null
var special_character: CharacterBody2D = null
@onready var special = $"../../NPC/Special"

@onready var minigame_manager = $"../../MinigameScreen/MiniGameManager"

@onready var task_list = $"../TaskList"

signal stage_finished(success: bool)

func _ready():
	employees = get_tree().get_nodes_in_group("employees")
	
	if GameData.stage_level >= 2:
		special_character_scene = load(special_event_resource_paths[GameData.stage_level - 2])
	
func _process(delta: float) -> void:
	if GameData.is_playing_minigame:
		GameData.main_time_scale = 0.5
	else:
		GameData.main_time_scale = 1.0


func _on_game_timer_timeout() -> void:
	print("time out!")
	await get_tree().create_timer(13).timeout
	get_tree().paused = true
	

func _on_game_timer_unit_time_passed() -> void:
	#print("one game minute passed!")
	handle_wandering_event()
	handle_coffee_order_event()
	handle_water_spill_event()
	
func _on_game_timer_one_hour_passed() -> void:
	game_hour += 1
	
	if game_hour == 12:
		handle_special_event()


func handle_wandering_event():
	if randf() < wandering_probability:
		var candidates = []
		for employee in employees:
			if employee.state == Employee.States.SITTING:
				candidates.append(employee)
		if !candidates.is_empty():
			var random_tile_position = Vector2i(randi_range(2, 13), randi_range(1, 10))
			var random_position = map.map_to_local(random_tile_position)
			candidates.pick_random().wander(random_position)

func handle_coffee_order_event():
	if randf() < coffee_order_probability:
		var candidates = []
		for employee in employees:
			if employee.state == Employee.States.SITTING:
				candidates.append(employee)
		if !candidates.is_empty():
			candidates.pick_random().order_coffee()

func handle_water_spill_event():
	if game_hour >= 17:
		return
	
	if randf() < water_spill_probability:
		var candidates = []
		for employee in employees:
			if employee.state == Employee.States.WANDERING:
				candidates.append(employee)
		if !candidates.is_empty():
			candidates.pick_random().spill_water()

func handle_special_event():
	var current_stage = GameData.stage_level
	
	if current_stage != 1:
		print("special NPC")
		special_character = special_character_scene.instantiate()
		special_character.global_position = Vector2(80, 48)
		special.add_child(special_character)
		
		if current_stage == 5:
			var boss: Boss = special_character
			boss.boss_talking.connect(_on_special_character_boss_talking)
			boss.add_to_group("boss")

func _on_special_character_boss_talking():
	minigame_manager.open_minigame(4)

func check_win_or_lose():
	if task_list.computer_task.is_empty() and task_list.copy_machine_task == 0 and task_list.water_clean_task == 0:
		stage_finished.emit(true)
	else:
		stage_finished.emit(false)
	
