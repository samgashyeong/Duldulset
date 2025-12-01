# 202126868 Minseo Choi
extends TextureRect
class_name FileIconUI

@export var is_trash: bool = false    # true = TrashFile*, false = NormalFile*

var original_parent: Node             # Original parent (for optional restore)
var original_index: int               # Original index in the parent
var original_position: Vector2        # Original position (not used in current logic)


func _ready() -> void:
	# Enable mouse interaction so this icon can start drag-and-drop
	mouse_filter = Control.MOUSE_FILTER_PASS

	# Store original parent and index in case we want to restore later
	original_parent = get_parent()
	original_index  = get_index()
	original_position = position


# Start drag: called when the user clicks and moves the mouse slightly
func _get_drag_data(at_position: Vector2) -> Variant:
	# Create a semi-transparent preview for Godot's default drag UI
	var preview := duplicate() as TextureRect
	preview.modulate.a = 0.7
	set_drag_preview(preview)

	# Drag payload data: TrashCan reads this dictionary on drop
	return {
		"node_path": get_path(),
		"is_trash": is_trash
	}
