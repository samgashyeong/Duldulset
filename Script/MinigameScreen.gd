extends Node

var minigame_manager
var player_computer
var copy_machine
var player

var current_minigame: String

func _ready():
	minigame_manager = $MiniGameManager
	minigame_manager.minigame_closed.connect(_on_minigame_manager_minigame_closed)
	minigame_manager.minigame_shown.connect(_on_minigame_manager_minigame_shown)
	
	player_computer = $"../Map/Tables/Part/PlayerDesk"
	player_computer.using_computer.connect(_on_player_computer_using_computer)

	copy_machine = $"../Map/Copy"
	copy_machine.using_copy_machine.connect(_on_copy_machine_using_copy_machine)
	
	player = $"../Giiyoung"
	
	current_minigame = ""

func _on_minigame_manager_minigame_closed(success: bool):
	GameData.is_playing_minigame = false
	
	if current_minigame == "CleaningWater":
		if success == true:
			get_tree().call_group("spilled_waters", "cleanup")

func _on_minigame_manager_minigame_shown(game_name: String):
	current_minigame = game_name
	print(current_minigame)
	
func _on_player_computer_using_computer():
	minigame_manager.open_minigame(0)

func _on_copy_machine_using_copy_machine():
	minigame_manager.open_minigame(1)
