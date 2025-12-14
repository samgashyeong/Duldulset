# 202322111 임상인
# This script is for managing minigames.

extends Node


# for referencing nodes in the MainGameScene
var minigame_manager

var player_computer

var copy_machine

@onready var player = $"../Giiyoung"

@onready var task_list: DailyTask = $"../GameSystem/TaskList"


var current_minigame: String


# It initializes.
func _ready():
	minigame_manager = $MiniGameManager
	minigame_manager.minigame_closed.connect(_on_minigame_manager_minigame_closed)
	minigame_manager.minigame_shown.connect(_on_minigame_manager_minigame_shown)
	
	player_computer = $"../Map/Tables/Part/PlayerDesk"
	player_computer.using_computer.connect(_on_player_computer_using_computer)

	copy_machine = $"../Map/Copy"
	copy_machine.using_copy_machine.connect(_on_copy_machine_using_copy_machine)
	
	current_minigame = ""


# It handles when the minigame is closed.
# for each minigame, when success, do proper task 
func _on_minigame_manager_minigame_closed(success: bool):
	GameData.is_playing_minigame = false
	
	if current_minigame == "CleaningWater":
		if success == true:
			get_tree().call_group("spilled_waters", "cleanup")
			var remaining = get_tree().get_node_count_in_group("spilled_waters")
			task_list.update_water_clean_task(remaining)
		
	if current_minigame == "DodgeGame":
		if success == true:
			get_tree().call_group("boss", "return_to_spawn")
	
	if current_minigame == "FileSorting" or current_minigame == "TypingReport":
		if success == true:
			task_list.pop_computer_task_queue()
			
	if current_minigame == "FixingPrinter":
		if success == true:
			task_list.update_copy_machine_task(-1)

# It handles when the minigame is opened.
func _on_minigame_manager_minigame_shown(game_name: String):
	# update current minigame information
	current_minigame = game_name
	print(current_minigame)


# It handles when the Player is using the Player's computer.
func _on_player_computer_using_computer():
	# get a task from the computer task queue
	var task_id = task_list.computer_task.front()
	
	# open proper minigame for each task
	match task_id:
		0:
			minigame_manager.open_minigame(1)
		1:
			minigame_manager.open_minigame(0)	

# It handles when the Player is using the copy machine.
func _on_copy_machine_using_copy_machine():
	# open fixing printer minigame
	minigame_manager.open_minigame(3)
