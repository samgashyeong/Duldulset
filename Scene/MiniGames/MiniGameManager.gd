# 202126868 Minseo Choi
extends Node
class_name MiniGameManager

# Emitted when main game should be paused or resumed
signal pause_requested(should_pause: bool)

# Emitted when a minigame window is opened (with its name)
signal minigame_shown(game_name: String)

# Emitted when a minigame is closed (with success / fail result)
signal minigame_closed(success: bool)

@export var should_auto_request_pause: bool = true   # If true, send pause_requested on open/close
@export var default_minigame_index: int = 0          # Used when no index is passed to open_minigame()

@export var minigame_scene_list: Array[PackedScene] = []  # Minigame scenes to instantiate

@onready var minigame_window: Window  = $MiniGameWindow
@onready var minigame_host: Control   = $MiniGameWindow/MiniGameHost

var active_minigame: Node = null          # Currently running minigame instance
var active_minigame_index: int = -1       # Index in minigame_scene_list of the active minigame
@export var is_window_open: bool = false          # True while the minigame window is visible


func _ready() -> void:
	# Prepare the window: start hidden and connect close signal
	minigame_window.hide()
	minigame_window.unresizable = true
	minigame_window.close_requested.connect(_on_window_close_requested)

	# Allow this node to receive input events (debug key shortcuts)
	set_process_input(true)


# Open a minigame by index (or use default_minigame_index when index < 0)
func open_minigame(index: int = -1) -> void:
	if is_window_open:
		return

	var target_index: int = index
	if target_index < 0:
		target_index = default_minigame_index

	# Validate index range
	if target_index < 0 or target_index >= minigame_scene_list.size():
		push_error("MiniGameManager: invalid minigame index %d" % target_index)
		return

	var packed_scene: PackedScene = minigame_scene_list[target_index]
	if packed_scene == null:
		push_error("MiniGameManager: scene at index %d is null." % target_index)
		return

	# Clean up previous instance if it somehow still exists
	if active_minigame and is_instance_valid(active_minigame):
		active_minigame.queue_free()
		active_minigame = null

	# Instantiate and store the new minigame
	active_minigame = packed_scene.instantiate()
	active_minigame_index = target_index

	# Connect common result signal if the minigame exposes it
	if active_minigame.has_signal("minigame_finished"):
		active_minigame.minigame_finished.connect(_on_minigame_finished)

	minigame_host.add_child(active_minigame)

	is_window_open = true

	# Show the popup window in the center of the screen
	minigame_window.popup_centered()

	emit_signal("minigame_shown", _get_game_name(target_index))

	# Optionally ask the main game to pause itself
	if should_auto_request_pause:
		emit_signal("pause_requested", true)


# Close the currently active minigame and emit result to listeners
func close_minigame(success: bool) -> void:
	if not is_window_open:
		return

	if active_minigame and is_instance_valid(active_minigame):
		active_minigame.queue_free()

	active_minigame = null
	active_minigame_index = -1

	minigame_window.hide()
	is_window_open = false

	emit_signal("minigame_closed", success)

	# Optionally ask the main game to resume
	if should_auto_request_pause:
		emit_signal("pause_requested", false)


# Debug key shortcuts: press 1~5 to open each minigame by index
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			Key.KEY_1:
				open_minigame(0)
			Key.KEY_2:
				open_minigame(1)
			Key.KEY_3:
				open_minigame(2)
			Key.KEY_4:
				open_minigame(3)
			Key.KEY_5:
				open_minigame(4)


# Called by minigame when it finishes via its minigame_finished signal
func _on_minigame_finished(success: bool) -> void:
	close_minigame(success)


# Called when the user clicks the window “X” button
func _on_window_close_requested() -> void:
	close_minigame(false)


# Resolve a human-readable minigame name from its index
func _get_game_name(idx: int) -> String:
	if idx < 0 or idx >= minigame_scene_list.size():
		return ""

	var packed_scene: PackedScene = minigame_scene_list[idx]
	if packed_scene == null:
		return "Game%d" % idx

	if packed_scene.resource_name != "":
		return packed_scene.resource_name

	if packed_scene.resource_path != "":
		return packed_scene.resource_path.get_file().get_basename()

	return "Game%d" % idx
