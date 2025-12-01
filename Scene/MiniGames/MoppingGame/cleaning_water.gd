# 202126868 Minseo Choi
# Water cleaning minigame: drag the mop over water stains and swipe left/right to clean them.
extends Control

# Number of required left-right strokes per water stain
@export var required_strokes_per_water: int = 10

# Minimum horizontal distance (pixels) to count as a valid side switch
@export var min_direction_switch_dx: float = 40.0

# If true, each water stain gradually fades out as it gets cleaned
@export var fade_water_on_progress: bool = true

# Water TextureRect nodes (set in the inspector).
# If empty, nodes whose names start with "Water" are detected automatically.
@export var water_node_paths: Array[NodePath] = []

# Mop TextureRect node path (set in the inspector)
@export var mop_node_path: NodePath

# Actual water TextureRect nodes used at runtime
@onready var water_nodes: Array[TextureRect] = []

# Mop TextureRect used for collision detection
@onready var mop_texture: TextureRect = get_node_or_null(mop_node_path)

# Emitted when the minigame ends (success = true/false)
signal minigame_finished(success: bool)


# Per-water state
var stroke_counts_for_water: Array[int] = []          # How many strokes each water has received
var previous_side_for_water: Array[int] = []          # -1 (left), 1 (right), 0 (not decided yet)
var last_cross_x_for_water: Array[float] = []         # Last X-position where a valid side switch happened
var is_water_cleaned_flags: Array[bool] = []          # true if this water is already fully cleaned

var current_water_index: int = -1                     # Index of the currently targeted water stain
var cleaned_water_count: int = 0                      # How many water stains are fully cleaned


func _ready() -> void:
	# Initialize water nodes and mop reference
	_init_water_nodes()
	_init_mop_node()

	# If we have no water or no mop, abort early
	if water_nodes.is_empty() or mop_texture == null:
		return

	# Initialize per-water arrays based on the number of water stains
	var water_count: int = water_nodes.size()
	stroke_counts_for_water.resize(water_count)
	previous_side_for_water.resize(water_count)
	last_cross_x_for_water.resize(water_count)
	is_water_cleaned_flags.resize(water_count)

	for i in water_count:
		stroke_counts_for_water[i] = 0
		previous_side_for_water[i] = 0
		last_cross_x_for_water[i] = 0.0
		is_water_cleaned_flags[i] = false

	current_water_index = -1
	cleaned_water_count = 0


# Find and store all water TextureRect nodes
func _init_water_nodes() -> void:
	water_nodes.clear()

	# If no paths are given, search children whose names start with "Water"
	if water_node_paths.is_empty():
		for child in get_children():
			if child is TextureRect and child.name.begins_with("Water"):
				water_nodes.append(child)
	else:
		# Use explicitly assigned NodePaths from the inspector
		for path in water_node_paths:
			var water_rect: TextureRect = get_node_or_null(path) as TextureRect
			if water_rect != null:
				water_nodes.append(water_rect)

	# If we still have no water nodes, print an error to help debugging
	if water_nodes.is_empty():
		push_error("cleaning_water.gd: Could not find any water TextureRect. " +
			"Set 'water_node_paths' or name nodes as 'Water1, Water2, ...'")
		print_tree()


# Validate mop TextureRect reference and warn if it is missing
func _init_mop_node() -> void:
	if mop_texture == null:
		push_error("cleaning_water.gd: Could not find mop TextureRect. " +
			"Set 'mop_node_path' or name the node 'Mop'.")
		print_tree()


# Main update loop: detect which water the mop is over and count swipes
func _process(_delta: float) -> void:
	if mop_texture == null or water_nodes.is_empty():
		return

	var mop_rect: Rect2 = mop_texture.get_global_rect()

	# Find which water, if any, the mop is currently overlapping (ignore already cleaned water)
	var overlapped_index: int = -1
	var water_count: int = water_nodes.size()
	for i in water_count:
		if is_water_cleaned_flags[i]:
			continue

		var water_rect: Rect2 = water_nodes[i].get_global_rect()
		if mop_rect.intersects(water_rect):
			overlapped_index = i
			break

	# If mop is not over any water stain, clear the current target and return
	if overlapped_index == -1:
		current_water_index = -1
		return

	# When switching to a different water stain, reset side and reference X-position
	if overlapped_index != current_water_index:
		current_water_index = overlapped_index
		previous_side_for_water[overlapped_index] = 0
		last_cross_x_for_water[overlapped_index] = mop_texture.global_position.x

	# Swipe detection logic based on mop position relative to the water center
	var active_water_rect: Rect2 = water_nodes[overlapped_index].get_global_rect()
	var center_x: float = active_water_rect.get_center().x
	var mop_x: float = mop_texture.global_position.x

	# side = 1 (right of center) / -1 (left of center)
	var current_side: int = 1 if mop_x >= center_x else -1
	var previous_side: int = previous_side_for_water[overlapped_index]

	# When side changes and previous side is valid, check if we moved far enough
	if current_side != previous_side and previous_side != 0:
		if absf(mop_x - last_cross_x_for_water[overlapped_index]) >= min_direction_switch_dx:
			stroke_counts_for_water[overlapped_index] += 1
			last_cross_x_for_water[overlapped_index] = mop_x
			_update_water_clean_progress(overlapped_index)

	# Store the side for the next frame comparison
	previous_side_for_water[overlapped_index] = current_side


# Update a single water stain's visual alpha and check if it is fully cleaned
func _update_water_clean_progress(water_index: int) -> void:
	var strokes: int = stroke_counts_for_water[water_index]

	# Gradually fade out the water stain depending on cleaning progress
	if fade_water_on_progress:
		var progress: float = clampf(float(strokes) / float(required_strokes_per_water), 0.0, 1.0)
		var water_rect: TextureRect = water_nodes[water_index]
		var color: Color = water_rect.modulate
		color.a = 1.0 - 0.85 * progress
		water_rect.modulate = color

	# Check if this water stain is now fully cleaned
	if strokes >= required_strokes_per_water and not is_water_cleaned_flags[water_index]:
		is_water_cleaned_flags[water_index] = true
		cleaned_water_count += 1

		# Make this water completely invisible
		var cleaned_water: TextureRect = water_nodes[water_index]
		var cleaned_color: Color = cleaned_water.modulate
		cleaned_color.a = 0.0
		cleaned_water.modulate = cleaned_color

		# If all water stains are cleaned, finish the minigame with success
		if cleaned_water_count >= water_nodes.size():
			_finish_minigame(true)


# Stop input on the mop and notify the parent that the minigame has finished
func _finish_minigame(success: bool) -> void:
	if mop_texture != null:
		mop_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE

	minigame_finished.emit(success)
