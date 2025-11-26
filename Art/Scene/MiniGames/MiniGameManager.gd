extends Node
class_name MiniGameManager

signal pause_requested(should_pause: bool)     # true면 메인 게임 일시정지 요청
signal minigame_shown(game_name: String)      # 어떤 미니게임이 열렸는지 알림
signal minigame_closed(success: bool)         # 성공/실패 여부와 함께 닫힘 알림

@export var auto_request_pause: bool = true   # true면 열릴 때 pause_requested(true), 닫힐 때 false
@export var default_game_index: int = 0

@export var minigame_scenes: Array[PackedScene] = []

@onready var minigame_window: Window = $MiniGameWindow
@onready var minigame_host: Control  = $MiniGameWindow/MiniGameHost

var active_game: Node = null
var active_index: int = -1
var _window_open: bool = false

func _ready() -> void:
	minigame_window.hide()
	minigame_window.unresizable = true
	minigame_window.close_requested.connect(_on_window_close_requested)
	set_process_input(true)       # 이 노드에서 키 입력 받기

func open_minigame(index: int = -1) -> void:
	if _window_open:
		return

	var idx := index
	if idx < 0:
		idx = default_game_index

	if idx < 0 or idx >= minigame_scenes.size():
		push_error("MiniGameManager: 잘못된 미니게임 인덱스 %d" % idx)
		return

	var ps: PackedScene = minigame_scenes[idx]
	if ps == null:
		push_error("MiniGameManager: 인덱스 %d에 씬이 비어 있습니다." % idx)
		return

	# 혹시 이전 게임 인스턴스가 남아 있으면 정리
	if active_game and is_instance_valid(active_game):
		active_game.queue_free()
		active_game = null

	active_game = ps.instantiate()
	active_index = idx

	if active_game.has_signal("minigame_finished"):
		active_game.minigame_finished.connect(_on_minigame_finished)

	minigame_host.add_child(active_game)

	_window_open = true
	minigame_window.popup_centered()

	emit_signal("minigame_shown", _get_game_name(idx))
	if auto_request_pause:
		emit_signal("pause_requested", true)

func close_minigame(success: bool) -> void:
	if not _window_open:
		return

	if active_game and is_instance_valid(active_game):
		active_game.queue_free()
	active_game = null
	active_index = -1

	minigame_window.hide()
	_window_open = false

	emit_signal("minigame_closed", success)
	if auto_request_pause:
		emit_signal("pause_requested", false)

# ─────────────────────────────
#  디버그용 숫자 키 입력 (1,2,3)
# ─────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			Key.KEY_1:
				open_minigame(0)     # 배열 0번
			Key.KEY_2:
				open_minigame(1)     # 배열 1번
			Key.KEY_3:
				open_minigame(2)     # 배열 2번


func _on_minigame_finished(success: bool) -> void:
	close_minigame(success)

func _on_window_close_requested() -> void:
	close_minigame(false)

func _get_game_name(idx: int) -> String:
	if idx < 0 or idx >= minigame_scenes.size():
		return ""
	var ps: PackedScene = minigame_scenes[idx]
	if ps == null:
		return "Game%d" % idx
	if ps.resource_name != "":
		return ps.resource_name
	if ps.resource_path != "":
		return ps.resource_path.get_file().get_basename()
	return "Game%d" % idx
