# 202126868 Minseo Choi
extends Control

var required_strokes_per_water: int = 10
var min_direction_switch_dx: float = 40.0	# Minimum horizontal distance (pixels)
var fade_water_on_progress: bool = true
@export var water_nodes: Array[TextureRect] = []
@export var mop_node_path: NodePath

@onready var mop_texture: TextureRect = $Mop
@onready var cleaning_sound: AudioStreamPlayer = $Sounds/CleaningSound
@onready var success_sound: AudioStreamPlayer = $Sounds/SuccessSound

# Emitted when the minigame ends (success = true/false)
signal minigame_finished(success: bool)


# Per-water state
var stroke_counts_for_water: Array[int] = []
var previous_side_for_water: Array[int] = []
var last_cross_x_for_water: Array[float] = []
var is_water_cleaned_flags: Array[bool] = []

var current_frame_water_index: int = -1
var cleaned_water_count: int = 0


func _ready() -> void:
	# Initialize water nodes and mop reference
	_init_water_nodes()

	# If we have no water or no mop, return
	if water_nodes.is_empty() or mop_texture == null:
		return

	# Initialize per-water arrays based on the number of waters
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

	current_frame_water_index = -1
	cleaned_water_count = 0


# Find and store all water TextureRect nodes
func _init_water_nodes() -> void:
	water_nodes.clear()

	# If no paths are given, search children whose names start with "Water"
	if water_nodes.is_empty():
		for child in get_children():
			if child is TextureRect and child.name.begins_with("Water"):
				water_nodes.append(child)


# Detect which water the mop is over and count swipes per framge
func _process(_delta: float) -> void:
	var mop_rect: Rect2 = mop_texture.get_global_rect()

	# Find which water the mop is currently cleaning
	var previous_frame_water_index: int = -1
	var water_count: int = water_nodes.size()
	for i in water_count:
		if is_water_cleaned_flags[i]:	# ignore cleaned water
			continue

		var water_rect: Rect2 = water_nodes[i].get_global_rect()
		if mop_rect.intersects(water_rect):
			previous_frame_water_index = i
			break

	# If mop is not over any water rect, clear the current target and return
	if previous_frame_water_index == -1:
		current_frame_water_index = -1
		return

	# When switching to a different water rect, reset side and reference X-position
	if previous_frame_water_index != current_frame_water_index:
		current_frame_water_index = previous_frame_water_index
		previous_side_for_water[previous_frame_water_index] = 0
		last_cross_x_for_water[previous_frame_water_index] = mop_texture.global_position.x

	# Swipe detection logic based on mop position relative to the water center
	var active_water_rect: Rect2 = water_nodes[previous_frame_water_index].get_global_rect()
	var center_x: float = active_water_rect.get_center().x
	var mop_x: float = mop_texture.global_position.x

	# side = 1 (right of center) / -1 (left of center)
	var current_side: int = 1 if mop_x >= center_x else -1
	var previous_side: int = previous_side_for_water[previous_frame_water_index]

	# When side changes and previous side is valid, check if we moved far enough
	if current_side != previous_side and previous_side != 0:
		if absf(mop_x - last_cross_x_for_water[previous_frame_water_index]) >= min_direction_switch_dx:
			stroke_counts_for_water[previous_frame_water_index] += 1
			last_cross_x_for_water[previous_frame_water_index] = mop_x
			SoundManager.play_Mopping_sound()
			_update_water_clean_progress(previous_frame_water_index)

	# Store the side for the next frame comparison
	previous_side_for_water[previous_frame_water_index] = current_side


# Update a single water stain's visual alpha and check if it is fully cleaned
func _update_water_clean_progress(water_index: int) -> void:
	var strokes: int = stroke_counts_for_water[water_index]

	# Fade out the water stain depending on cleaning progress
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

		SoundManager.play_Waterclean_sound()

		# Make this water completely invisible
		var cleaned_water: TextureRect = water_nodes[water_index]
		var cleaned_color: Color = cleaned_water.modulate
		cleaned_color.a = 0.0
		cleaned_water.modulate = cleaned_color

		# If all water stains are cleaned, finish the minigame with success
		if cleaned_water_count >= water_nodes.size():
			if success_sound:
				success_sound.play()
			else:
				_on_success_sound_finished()


# Stop input on the mop and notify the parent that the minigame has finished
func _on_success_sound_finished() -> void:
	minigame_finished.emit(true)
