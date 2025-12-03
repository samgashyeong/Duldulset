extends TextureRect
class_name FileIconUI

@export var is_trash: bool = false    # TrashFile* = true, NormalFile* = false
var origin_parent: Node               # 실패 시 되돌릴 부모
var origin_index: int                 # 실패 시 되돌릴 인덱스
var origin_pos: Vector2               # 절대 배치가 아니라면 불필요

func _ready() -> void:
	# 마우스 이벤트 받기
	mouse_filter = Control.MOUSE_FILTER_PASS
	origin_parent = get_parent()
	origin_index  = get_index()

# 드래그 시작: 마우스 다운 후 살짝 움직이면 호출됨
func _get_drag_data(at_position: Vector2) -> Variant:
	
	var preview := duplicate() as TextureRect    # 드래그 미리보기
	preview.modulate.a = 0.7
	set_drag_preview(preview)

	# 드래그 페이로드(휴지통이 읽음)
	return {
		"node_path": get_path(),
		"is_trash": is_trash
	}

# 드래그 중 아이콘을 원래 자리에서 ‘비워’ 보이고 싶다면:
#func _gui_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 클릭 시작 시 현재 위치 백업이 필요하면 여기서 저장
#		pass
