# 202126868 Minseo Choi
extends Control

# Emitted when the file-sorting minigame ends (success = true/false)
signal minigame_finished(success: bool)

@onready var files_root: Control = $Files      # Parent node that contains all file icons
@onready var trash_can: Control  = $TrashCan  # Trashcan control used as drop target


# Runtime state
var total_trash_count: int = 0        # Total number of trash file icons in this minigame
var removed_trash_count: int = 0      # How many trash files have been correctly removed so far
var is_minigame_finished: bool = false  # True after the minigame has ended

var last_result_success: bool = false  # Stores last game result (true = win, false = lose)


func _ready() -> void:
	# Count how many trash files exist at the start of the minigame
	_count_trash_files()
	# Randomize file icon positions inside a 5x4 grid
	_randomize_file_positions()
	_debug_print_file_positions()   # ← 디버깅용 출력

# Print all file icon positions for debugging
func _debug_print_file_positions() -> void:
	print("===== FileIconUI positions (local / global) =====")
	for child in files_root.get_children():
		if child is FileIconUI:
			var icon := child as FileIconUI
			var local_pos: Vector2 = icon.position
			var global_pos: Vector2 = icon.global_position

			print(
				"[", icon.name, "]  ",
				"local = ", local_pos,
				"  global = ", global_pos
			)
	print("===============================================")

# Count all trash file icons under files_root
func _count_trash_files() -> void:
	total_trash_count = 0
	removed_trash_count = 0

	for child in files_root.get_children():
		if child is FileIconUI and child.name.begins_with("TrashFile"):
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

	# Collect all file icons under files_root (exclude TrashCan and others)
	var file_icons: Array[FileIconUI] = []
	for child in files_root.get_children():
			file_icons.append(child)

	# Safety check: more files than slots → 일부는 그대로 남게 됨
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



# Called by TrashCan when one trash file has been correctly removed
func _on_trash_removed() -> void:
	if is_minigame_finished:
		return

	removed_trash_count += 1

	# When all trash files are removed, the player wins
	if removed_trash_count >= total_trash_count:
		_finish(true)


# Finish the minigame and disable mouse interaction on all file controls
func _finish(success: bool) -> void:
	if is_minigame_finished:
		return

	is_minigame_finished = true
	last_result_success = success

	# Disable mouse input for all file-related controls after the game ends
	for child in files_root.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Notify MiniGameManager (or parent controller) that this minigame ended
	minigame_finished.emit(success)
