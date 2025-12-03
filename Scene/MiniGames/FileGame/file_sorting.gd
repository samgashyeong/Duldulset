# 202126868 Minseo Choi
extends Control

# Emitted when the file-sorting minigame ends (success = true/false)
signal minigame_finished(success: bool)

@onready var files_root: Control = $Files      # Parent node that contains all file icons
@onready var trash_can: Control  = $TrashCan  # Trashcan control used as drop target

@onready var click_sound: AudioStreamPlayer = $Sounds/ClickSound
@onready var error_sound: AudioStreamPlayer = $Sounds/ErrorSound
@onready var success_sound: AudioStreamPlayer = $Sounds/SuccessSound

@onready var success_panel: Control = $SuccessPanel
@onready var success_panel_timer: Timer = $SuccessPanel/SuccessPanelTimer

@onready var error_panel: Control = $ErrorPanel
@onready var error_panel_timer: Timer = $ErrorPanel/ErrorPanelTimer
# Runtime state
var total_trash_count: int = 0
var removed_trash_count: int = 0


func _ready() -> void:
	_count_trash_files()
	# Randomize file icon positions inside a 5x4 grid
	_randomize_file_positions()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		if click_sound:
			click_sound.play()

# Count all trash file icons under files_root
func _count_trash_files() -> void:
	total_trash_count = 0
	removed_trash_count = 0

	for child in files_root.get_children():
		if child is File and child.name.begins_with("TrashFile"):
			total_trash_count += 1


# Randomize FileIconUI positions in a 5x4 grid under files_root
func _randomize_file_positions() -> void:
	# Define grid coordinates (5 columns × 4 rows)
	var x_positions: Array[float] = [16.0, 80.0, 144.0, 208.0, 272.0]
	var y_positions: Array[float] = [8.0, 72.0, 136.0, 200.0]

	# Build all possible grid slots as local positions
	var grid_slots: Array[Vector2] = []
	for y in y_positions:
		for x in x_positions:
			grid_slots.append(Vector2(x, y))

	# Collect all file icons under files_root
	var file_icons: Array[File] = []
	for child in files_root.get_children():
			file_icons.append(child)

	# Safety check: more files than slots
	if file_icons.size() > grid_slots.size():
		push_warning("FileSorting: more FileIconUI nodes than available grid slots.")

	# Shuffle slots to randomize placement
	grid_slots.shuffle()

	# Assign each file icon to a unique slot (no overlap)
	for icon in file_icons:
		if grid_slots.is_empty():
			break

		# Take one slot and remove it from the list so it cannot be reused
		var slot: Vector2 = grid_slots.pop_back()
		icon.position = slot


# Called when trash file has been correctly removed
func _on_trash_removed() -> void:
	removed_trash_count += 1
	SoundManager.play_Erasefile_sound()

	# When all trash files are removed, the player wins
	if removed_trash_count >= total_trash_count:
		_finish_minigame(true)

func _finish_minigame(success: bool) -> void:
	if success:
		if success_sound:
			success_sound.play()
		success_panel.visible = true
		success_panel_timer.start()
	else:
		if error_sound:
			error_sound.play(0.5)
		error_panel.visible = true
		error_panel_timer.start()

# Finish the minigame and emit the result to minigamemanager
func _on_success_panel_timer_timeout() -> void:
	success_panel.visible = false
	minigame_finished.emit(true)

func _on_error_panel_timer_timeout() -> void:
	error_panel.visible = false
	minigame_finished.emit(false)
