# 202126868 Minseo Choi
extends TextureRect
class_name File

@export var is_trash: bool = false


func _ready() -> void:
	# Enable mouse interaction so this icon can start drag-and-drop
	mouse_filter = Control.MOUSE_FILTER_PASS


# Start drag: called when the user clicks and moves the mouse slightly
func _get_drag_data(at_position: Vector2) -> Variant:
	# Create a semi-transparent preview for drag Icon
	var preview := duplicate() as TextureRect
	preview.modulate.a = 0.7
	set_drag_preview(preview)

	# TrashCan reads this dictionary on drop
	return {
		"node_path": get_path(),
		"is_trash": is_trash
	}
