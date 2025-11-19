extends TextureRect

var is_on_trashcan := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		var d: Dictionary = data
		var is_vaild_file: bool = d.has("node_path") and d.has("is_trash")
		is_on_trashcan = is_vaild_file
		if is_vaild_file:
			modulate = Color(0.0, 0.0, 1.0, 1.0)
		return is_vaild_file
	is_on_trashcan = false
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	is_on_trashcan = false
	modulate = Color(1,1,1,1)

	if not (data is Dictionary):
		return
	var d: Dictionary = data

	var dragged_icon_node: Node = get_node_or_null(d.get("node_path", NodePath()))
	if dragged_icon_node == null:
		return

	var is_trash: bool = bool(d.get("is_trash", false))
	var root :=_find_root()
	if is_trash:
		dragged_icon_node.queue_free()
		if root:
			root._on_trash_removed()
	else:
		if root:
			root._finish(false)

func _notification(what):
	if what == NOTIFICATION_DRAG_END and is_on_trashcan:
		is_on_trashcan = false
		modulate = Color(1,1,1,1)

func _find_root() -> Node:
	var n: Node = self
	while n and not n.has_method("_finish"):
		n = n.get_parent()
	return n
