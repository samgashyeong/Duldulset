# cleaning_water.gd
extends Control

@export var strokes_per_water: int = 10         # 각 물당 필요한 스와이프 수
@export var min_switch_dx: float = 40.0         # 좌↔우 전환으로 인정할 최소 이동 거리(px)
@export var fade_on_progress: bool = true

# 물 노드들을 인스펙터에서 지정 (비워두면 이름이 "Water"로 시작하는 자식들을 자동 검색)
@export var water_paths: Array[NodePath] = []

@export var mop_path: NodePath

@onready var waters: Array[TextureRect] = []    # 실제 물 노드들
@onready var mop: TextureRect = get_node_or_null(mop_path)

signal minigame_finished(success: bool)

# 물별 상태
var _strokes_for: Array[int] = []
var _prev_side_for: Array[int] = []             # -1 / 1 / 0
var _last_cross_x_for: Array[float] = []
var _cleaned_for: Array[bool] = []

var _current_index: int = -1                    # 현재 문지르고 있는 물 인덱스
var _cleaned_count: int = 0                     # 청소 완료된 물 개수

func _ready() -> void:
	_init_waters()
	_init_mop()

	if waters.is_empty() or mop == null:
		return

	var n: int = waters.size()
	_strokes_for.resize(n)
	_prev_side_for.resize(n)
	_last_cross_x_for.resize(n)
	_cleaned_for.resize(n)

	for i in n:
		_strokes_for[i] = 0
		_prev_side_for[i] = 0
		_last_cross_x_for[i] = 0.0
		_cleaned_for[i] = false

	_current_index = -1
	_cleaned_count = 0

func _init_waters() -> void:
	waters.clear()

	if water_paths.is_empty():
		for child in get_children():
			if child is TextureRect and child.name.begins_with("Water"):
				waters.append(child)
	else:
		for p in water_paths:
			var w: TextureRect = get_node_or_null(p) as TextureRect
			if w != null:
				waters.append(w)

	if waters.is_empty():
		push_error("cleaning_water.gd: 물 TextureRect를 찾을 수 없습니다. water_paths를 설정하거나 노드 이름을 'Water1, Water2, ...' 형식으로 맞추세요.")
		print_tree()

func _init_mop() -> void:
	if mop == null:
		push_error("cleaning_water.gd: Mop TextureRect를 찾을 수 없습니다. mop_path를 설정하거나 노드 이름을 'Mop'으로 맞추세요.")
		print_tree()

func _process(_delta: float) -> void:
	if mop == null or waters.is_empty():
		return

	var mr: Rect2 = mop.get_global_rect()

	# 현재 mop이 어떤 물 위에 있는지 찾기 (이미 청소된 물은 제외)
	var idx: int = -1
	var n: int = waters.size()
	for i in n:
		if _cleaned_for[i]:
			continue
		var wr: Rect2 = waters[i].get_global_rect()
		if mr.intersects(wr):
			idx = i
			break

	if idx == -1:
		# 물 위에 없으면 현재 타겟 해제
		_current_index = -1
		return

	# 다른 물로 이동했으면 방향/기준점 초기화
	if idx != _current_index:
		_current_index = idx
		_prev_side_for[idx] = 0
		_last_cross_x_for[idx] = mop.global_position.x

	# 현재 타겟 물 기준으로 스와이프 판정
	var wr_active: Rect2 = waters[idx].get_global_rect()
	var center_x: float = wr_active.get_center().x
	var x: float = mop.global_position.x
	var side: int = 1 if x >= center_x else -1

	var prev_side: int = _prev_side_for[idx]
	if side != prev_side and prev_side != 0:
		if absf(x - _last_cross_x_for[idx]) >= min_switch_dx:
			_strokes_for[idx] += 1
			
			#쓱싹소리시작
			SoundManager.play_Mopping_sound()
			#쓱싹소리끝
			
			_last_cross_x_for[idx] = x
			_update_water_progress(idx)

	_prev_side_for[idx] = side

func _update_water_progress(idx: int) -> void:
	var strokes: int = _strokes_for[idx]

	# 해당 물만 점점 투명하게
	if fade_on_progress:
		var t: float = clampf(float(strokes) / float(strokes_per_water), 0.0, 1.0)
		var w: TextureRect = waters[idx]
		var c: Color = w.modulate
		c.a = 1.0 - 0.85 * t
		w.modulate = c

	# 청소 완료 판정
	if strokes >= strokes_per_water and not _cleaned_for[idx]:
		_cleaned_for[idx] = true
		_cleaned_count += 1
		
		#물지움소리시작
		SoundManager.play_Waterclean_sound()
		#물지움소리끝

		# 완전히 안 보이게
		var w2: TextureRect = waters[idx]
		var c2: Color = w2.modulate
		c2.a = 0.0
		w2.modulate = c2

		if _cleaned_count >= waters.size():
			_finish(true)

func _finish(success: bool) -> void:
	if mop != null:
		mop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minigame_finished.emit(success)
