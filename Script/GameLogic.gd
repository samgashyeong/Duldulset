# 202322111 임상인
# This script is for handling core game logic.

extends Node

# for the game core logics
var wandering_probability = 0.1
var coffee_order_probability: float
var water_spill_probability = 0.01

var game_hour: int = 9


# for referencing nodes in the MainGameScene
var employees

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


# signal for notifiying the stage has finished
signal stage_finished(success: bool)


# It initializes.
func _ready():
	# get the all employees in the MainGameScene
	employees = get_tree().get_nodes_in_group("employees")
	
	# set coffee order probability of the Employee
	set_coffee_order_probability()
	
	# prepare special event
	if GameData.stage_level >= 2:
		special_character_scene = load(special_event_resource_paths[GameData.stage_level - 2])


# This function manipulates main time scale when playing minigames or not.
func _process(delta: float) -> void:
	if GameData.is_playing_minigame:
		GameData.main_time_scale = 0.5
	else:
		GameData.main_time_scale = 1.0


# This function sets coffee order probability of the Employee dynamically.
func set_coffee_order_probability():
	if GameData.stage_level == 5:
		coffee_order_probability = 0.0315
	else:
		coffee_order_probability = 0.005 + 0.00625 * GameData.stage_level # 0.03 for stage 4.	


# It handles when the game timer for the stage is timeout.
func _on_game_timer_timeout() -> void:
	print("time out!")
	# wait 13 seconds
	await get_tree().create_timer(13).timeout
	# and then check win or lose
	check_win_or_lose()

# It handles when each 1 game minute passed.
# Core events are handled by this function.
func _on_game_timer_unit_time_passed() -> void:
	handle_wandering_event()
	handle_coffee_order_event()
	handle_water_spill_event()

# It handles when each 1 game hour passed.
func _on_game_timer_one_hour_passed() -> void:
	game_hour += 1
	
	# if game hour is 12 o'clock, do special event
	if game_hour == 12:
		handle_special_event()


# This function handles wandering event of the employees.
func handle_wandering_event():
	# if the probability condition met
	if randf() < wandering_probability:
		var candidates = []
		
		# get employees who are sitting on their seat
		for employee in employees:
			if employee.state == Employee.States.SITTING:
				candidates.append(employee)
		
		if !candidates.is_empty():
			# pick a random tile position
			var random_tile_position = Vector2i(randi_range(2, 13), randi_range(1, 10))
			var random_position = map.map_to_local(random_tile_position)
			
			# pick a random employee from the candidates and make them wander
			candidates.pick_random().wander(random_position)


# This function handles coffee order event of the employees.
func handle_coffee_order_event():
	# if the probability condition met
	if randf() < coffee_order_probability:
		var candidates = []
		
		# get employees who are sitting on their seat
		for employee in employees:
			if employee.state == Employee.States.SITTING:
				candidates.append(employee)
		
		if !candidates.is_empty():
			# pick a random employee from the candidates and make them order a coffee
			candidates.pick_random().order_coffee()


# This function handles water spill event of the employees.
func handle_water_spill_event():
	# if game hour is 17 o'clock or later then don't spill water
	if game_hour >= 17:
		return
	
	# if the probability condition met
	if randf() < water_spill_probability:
		var candidates = []
		
		# get employees who are wandering
		for employee in employees:
			if employee.state == Employee.States.WANDERING:
				candidates.append(employee)
		
		if !candidates.is_empty():
			# pick a random employee from the candidates and make them spill water
			candidates.pick_random().spill_water()


# This function handles the special events.
func handle_special_event():
	var current_stage = GameData.stage_level
	
	# There should be special event except the stage 1
	if current_stage != 1:
		print("special NPC")
		special_character = special_character_scene.instantiate()
		special_character.global_position = Vector2(80, 48)
		special.add_child(special_character)
		
		# stage 5 is the Boss special event
		if current_stage == 5:
			var boss: Boss = special_character
			boss.boss_talking.connect(_on_special_character_boss_talking)
			boss.add_to_group("boss")


# This function handles when the Boss NPC is talking to the Player.
func _on_special_character_boss_talking():
	# open the boss dodge minigame
	minigame_manager.open_minigame(4)


# This function checks winning conditions and emit stage finished signal with win or lose information.
func check_win_or_lose():
	if task_list.computer_task.is_empty() and task_list.copy_machine_task == 0 and task_list.water_clean_task == 0:
		stage_finished.emit(true)
	else:
		stage_finished.emit(false)
	
