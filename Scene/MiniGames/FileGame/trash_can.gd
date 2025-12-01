# 202126868 Minseo Choi
extends TextureRect

@export var correct_drop_texture: Texture2D    # Texture shown when a correct trash file is dropped
@export var normal_texture: Texture2D          # Default trashcan texture

var is_drag_over_trashcan: bool = false        # True while a valid file is being dragged over this trashcan


func _ready() -> void:
	# Enable mouse interaction so this node can receive drop events
	mouse_filter = Control.MOUSE_FILTER_STOP

	# If normal_texture is not assigned, use the current texture as default
	if normal_texture == null:
		normal_texture = texture


# Decide whether this trashcan can accept the dragged data
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		var drag_data: Dictionary = data
		var is_valid_file: bool = drag_data.has("node_path") and drag_data.has("is_trash")
		is_drag_over_trashcan = is_valid_file

		# Highlight trashcan while a valid file is hovering over it
		if is_valid_file:
			modulate = Color(0.0, 0.0, 1.0, 0.8)
		return is_valid_file

	is_drag_over_trashcan = false
	return false


# Handle drop logic when a file icon is released over the trashcan
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	is_drag_over_trashcan = false
	modulate = Color(1, 1, 1, 1) # Reset color tint

	if not (data is Dictionary):
		return

	var drag_data: Dictionary = data

	var dragged_icon_node: Node = get_node_or_null(drag_data.get("node_path", NodePath()))
	if dragged_icon_node == null:
		return

	var is_trash_file: bool = bool(drag_data.get("is_trash", false))
	var root_minigame := _find_root_minigame()

	if is_trash_file:
		# Correct trash file dropped into trashcan
		# Change trashcan texture to indicate successful removal
		if correct_drop_texture != null:
			texture = correct_drop_texture

		# Remove the icon node from the scene
		dragged_icon_node.queue_free()

		# Notify the file-sorting controller that one trash file was removed
		if root_minigame:
			root_minigame._on_trash_removed()
	else:
		# Wrong (normal) file dropped into trashcan → end minigame as failure
		if root_minigame:
			root_minigame._finish(false)


# Reset highlight when drag ends but drop did not occur on this trashcan
func _notification(what):
	if what == NOTIFICATION_DRAG_END and is_drag_over_trashcan:
		is_drag_over_trashcan = false
		modulate = Color(1, 1, 1, 1)


# Find the root minigame controller that implements _finish()
func _find_root_minigame() -> Node:
	var node: Node = self
	while node and not node.has_method("_finish"):
		node = node.get_parent()
	return node


# Reset trashcan texture and state when restarting the minigame
func reset_texture() -> void:
	if normal_texture != null:
		texture = normal_texture

	modulate = Color(1, 1, 1, 1)
	is_drag_over_trashcan = false
