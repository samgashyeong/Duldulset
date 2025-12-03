extends Control

signal minigame_finished(success: bool)

@onready var files_root: Control = $Files
@onready var trash_can: Control  = $Files/TrashCan

var total_trash := 0
var removed_trash := 0
var finished := false

var result_success: bool = false

func _ready() -> void:
	#pause_mode = Node.PAUSE_MODE_PROCESS
	_count_trash()

func _count_trash() -> void:
	total_trash = 0
	removed_trash = 0
	for c in files_root.get_children():
		if c is FileIconUI and c.name.begins_with("TrashFile"):
			total_trash += 1

func _on_trash_removed() -> void:
	if finished: 
		return
	
	#쓰레기소리시작
	SoundManager.play_Erasefile_sound()
	#쓰레기소리끝
	
	removed_trash += 1
	if removed_trash >= total_trash:
		_finish(true)

func _finish(success: bool) -> void:
	if finished: 
		return
	finished = true
	result_success = success
	for c in files_root.get_children():
		if c is Control:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
	minigame_finished.emit(success)
