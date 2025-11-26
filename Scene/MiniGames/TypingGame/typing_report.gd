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

	if not input.text_submitted.is_connected(_on_line_edit_submitted):
		input.text_submitted.connect(_on_line_edit_submitted)

	input.clear()
	input.grab_focus()

func _on_line_edit_submitted(text: String) -> void:
	_check(text)

func _on_submit_pressed() -> void:
	_check(input.text)

func _check(user_input: String) -> void:
	var typed := _normalize(user_input)
	if typed == "":
		return

	var idx := _find_match_index(typed)
	if idx >= 0:	#If word is correct
		_labels[idx].visible = false
		_alive_count -= 1
		input.clear()
		if _alive_count <= 0:
			_finish(true)
	else:	#If word is incorrect
		_on_wrong_answer()
		input.clear()
		input.select_all()

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
	minigame_finished.emit(success)
