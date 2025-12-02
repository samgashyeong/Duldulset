# 202126868 Minseo Choi
extends TextureRect

@export var correct_drop_texture: Texture2D    # Trashcan texture shown when a trash file is dropped
@export var normal_texture: Texture2D          # Normal trashcan texture

var is_drag_over_trashcan: bool = false


func _ready() -> void:
	# Enable mouse interaction so this icon can start drag-and-drop
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

		# Apply blue filter on trashcan while a valid file is hovering over it
		if is_valid_file:
			modulate = Color(0.0, 0.0, 1.0, 0.8)
		return is_valid_file

	is_drag_over_trashcan = false
	return false


# Handle drop logic when a file icon is released over the trashcan
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	is_drag_over_trashcan = false
	modulate = Color(1, 1, 1, 1) # Reset blue filter on trashcan

	if not (data is Dictionary):
		return

	var drag_data: Dictionary = data

	var dragged_icon_node: Node = get_node_or_null(drag_data.get("node_path", NodePath()))
	if dragged_icon_node == null:
		return

	var is_trash_file: bool = bool(drag_data.get("is_trash", false))
	var root_minigame := _find_root_minigame()

	if is_trash_file:
		# Change trashcan texture to indicate successful removal
		if correct_drop_texture != null:
			texture = correct_drop_texture

		# Remove the dragged icon node from the scene
		dragged_icon_node.queue_free()

		# Notify the file-sorting controller that one trash file was removed
		if root_minigame:
			root_minigame._on_trash_removed()
	else:
		# If important(normal) file dropped into trashcan -> end minigame as failure
		if root_minigame:
			root_minigame._finish_minigame(false)


# Find the root minigame controller that implements _finish_minigame()
func _find_root_minigame() -> Node:
	var node: Node = self
	while node and not node.has_method("_finish_minigame"):
		node = node.get_parent()
	return node
