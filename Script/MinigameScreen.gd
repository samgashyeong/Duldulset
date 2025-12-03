extends Node

var minigame_manager
var player_computer
var copy_machine

func _ready():
	minigame_manager = $MiniGameManager
	minigame_manager.minigame_closed.connect(_on_minigame_manager_minigame_closed)
	
	player_computer = $"../Map/Tables/Part/PlayerDesk"
	player_computer.using_computer.connect(_on_player_computer_using_computer)
	
	copy_machine = $"../Map/Copy"
	copy_machine.using_copy_machine.connect(_on_copy_machine_using_copy_machine)


func _on_minigame_manager_minigame_closed(success: bool):
	GameData.is_playing_minigame = false
	
func _on_player_computer_using_computer():
	minigame_manager.open_minigame(0)

func _on_copy_machine_using_copy_machine():
	minigame_manager.open_minigame(1)
