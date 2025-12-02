# 202126868 Minseo Choi
extends Node
class_name MiniGameManager

signal minigame_shown(game_name: String)		# Emitted when a minigame is opened (with its name)
signal minigame_closed(success: bool)		# Emitted when a minigame is closed with state

@export var default_minigame_index: int = 0

@export var minigame_scene_list: Array[PackedScene] = []  # Minigame scenes to instantiate

@onready var minigame_window: Window  = $MiniGameWindow
@onready var minigame_host: Control   = $MiniGameWindow/MiniGameHost

var active_minigame: Node = null          # Currently running minigame instance
var active_minigame_index: int = -1       # Index of the active minigame
@export var is_window_open: bool = false  # True while the minigame window is visible


func _ready() -> void:
	# Initiate minigame window
	minigame_window.hide()
	minigame_window.unresizable = true
	minigame_window.close_requested.connect(_on_window_close_requested)

	# Allow this node to receive input events
	set_process_input(true)


# Open a minigame by index
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

	# Remove previous instance
	if active_minigame and is_instance_valid(active_minigame):
		active_minigame.queue_free()
		active_minigame = null

	# Instantiate and store new minigame
	active_minigame = packed_scene.instantiate()
	active_minigame_index = target_index

	# Connect common result signal
	if active_minigame.has_signal("minigame_finished"):
		active_minigame.minigame_finished.connect(_on_minigame_finished)

	minigame_host.add_child(active_minigame)

	is_window_open = true

	# Show the popup window in the center of the screen
	minigame_window.popup_centered()

	emit_signal("minigame_shown", _get_game_name(target_index))


# Close the current active minigame and emit result signal
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


# Called when minigame finishes by minigame_finished signal
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
