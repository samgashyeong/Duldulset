# TypingReport.gd
extends Control

@export_range(1, 3, 1) var difficulty: int = 1           # 1/2/3
@export var fill_random_order: bool = true               # 라벨에 채울 때 섞기
@export var case_insensitive: bool = true                # 대소문자 무시
@export var trim_spaces: bool = true                     # 앞뒤/중복 공백 정리
@export var normalize_hyphen: bool = true                # –— → -

@export var words_set_1: Array[String] = [
	"scope","owner","metric","budget","risk","trend","issue","draft","deploy","access"
]
@export var words_set_2: Array[String] = [
	"milestone","deliverable","throughput","baseline","rollback",
	"playbook","benchmark","refactor","postmortem","retention"
]
@export var words_set_3: Array[String] = [
	"executive summary","root cause analysis","risk mitigation","least privilege",
	"service level objective","user onboarding","key management","data drift","audit log"
]

@onready var input: LineEdit        = $LineEdit
@onready var grid: GridContainer    = $WordPanel/GridContainer

# 결과(미니게임 매니저가 읽을 수 있도록)
signal minigame_finished(success: bool)

# 내부 상태
var _labels: Array[Label] = []
var _alive_count: int = 0
var _force_focus: bool = true  # 강제 포커스 활성화

func _input(event: InputEvent) -> void:
	# 게임 진행 중이고 포커스가 없다면 강제로 포커스 설정
	if _force_focus and _alive_count > 0 and input != null and input.editable:
		if not input.has_focus() and (event is InputEventKey):
			input.grab_focus()
			# 입력 이벤트를 LineEdit로 전달
			get_viewport().set_input_as_handled()

func _ready() -> void:
	if grid == null:
		push_error("TypingReport: $WordPanel/GridContainer 경로를 확인하세요.")
		print_tree()
		return
		
	if input == null:
		push_error("TypingReport: $LineEdit 경로를 확인하세요.")
		print_tree()
		return

	_labels.clear()
	for c in grid.get_children():
		if c is Label:
			_labels.append(c)

	if _labels.is_empty():
		push_error("TypingReport: GridContainer 안에 Label 블록이 없습니다.")
		return

	var picked := _pick_words_for_labels(_get_words_for_difficulty(difficulty), _labels.size())
	for i in _labels.size():
		_labels[i].text = picked[i]
		_labels[i].visible = true

	_alive_count = _labels.size()

	# LineEdit 설정 강화
	input.focus_mode = Control.FOCUS_ALL
	input.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# text_submitted 대신 _unhandled_key_input 사용
	# if not input.text_submitted.is_connected(_on_line_edit_submitted):
	# 	input.text_submitted.connect(_on_line_edit_submitted)
	
	# focus_exited 신호도 연결하여 포커스 잃을 때 다시 가져오기
	if not input.focus_exited.is_connected(_on_focus_lost):
		input.focus_exited.connect(_on_focus_lost)

	input.clear()
	input.grab_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			var current_text = input.text
			input.clear()  # 즉시 텍스트 지우기
			_check(current_text)
			get_viewport().set_input_as_handled()  # 엔터 이벤트 소비

func _on_line_edit_submitted(text: String) -> void:
	_check(text)
	# 여러 방법으로 포커스 유지 시도
	call_deferred("_ensure_focus")

func _on_focus_lost() -> void:
	# 게임이 진행 중이면 포커스를 다시 가져옴
	if _alive_count > 0 and input.editable:
		call_deferred("_force_grab_focus")

func _on_submit_pressed() -> void:
	_check(input.text)

func _check(user_input: String) -> void:
	var typed := _normalize(user_input)
	if typed == "":
		# 빈 입력이어도 포커스 유지
		call_deferred("_force_grab_focus")
		return

	var idx := _find_match_index(typed)
	if idx >= 0:	#If word is correct
		_labels[idx].visible = false
		_alive_count -= 1
		# input.clear()  # 이미 _unhandled_key_input에서 처리함
		if _alive_count <= 0:
			_finish(true)
		else:
			# 정답 후 즉시 포커스 재설정
			call_deferred("_force_grab_focus")
	else:	#If word is incorrect
		_on_wrong_answer()
		# input.clear()  # 이미 _unhandled_key_input에서 처리함
		# 오답 후 즉시 포커스 재설정
		call_deferred("_force_grab_focus")

func _force_grab_focus() -> void:
	# 매우 강력한 포커스 설정
	if _alive_count > 0 and input.editable:
		input.grab_focus()
		input.caret_column = input.text.length()  # 커서를 끝으로

func _on_wrong_answer() -> void:
	pass

func _find_match_index(typed_norm: String) -> int:
	for i in _labels.size():
		var lbl := _labels[i]
		if not lbl.visible:
			continue
		var target_norm := _normalize(lbl.text)
		if typed_norm == target_norm:
			return i
	return -1

func _normalize(s: String) -> String:
	var t := s
	if trim_spaces:
		t = t.strip_edges()
		var re := RegEx.new()
		re.compile("\\s+")
		t = re.sub(t, " ", true)  # 연속 공백 1칸으로
	if normalize_hyphen:
		t = t.replace("–","-").replace("—","-")
	if case_insensitive:
		t = t.to_lower()
	return t

func _get_words_for_difficulty(d: int) -> Array[String]:
	match d:
		1: return words_set_1.duplicate()
		2: return words_set_2.duplicate()
		3: return words_set_3.duplicate()
		_: return words_set_1.duplicate()

func _pick_words_for_labels(pool: Array[String], need: int) -> Array[String]:
	var out := pool.duplicate()
	if fill_random_order:
		out.shuffle()
	if out.size() < need:
		var i := 0
		while out.size() < need and pool.size() > 0:
			out.append(pool[i % pool.size()])
			i += 1
	elif out.size() > need:
		out.resize(need)
	return out

func _finish(success: bool) -> void:
	input.editable = false
	_force_focus = false  # 강제 포커스 비활성화
	minigame_finished.emit(success)
