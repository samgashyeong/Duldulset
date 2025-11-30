extends Control
class_name DodgeGame

signal minigame_finished(success: bool)   # MiniGameManager에서 받는 공통 시그널

@export var boss_speed: float = 120.0         # 부장님 상하 이동 속도
@export var shoot_interval: float = 0.8       # 잔소리 발사 간격(초)
@export var projectile_speed: float = 400.0   # 잔소리 날아가는 속도(px/sec)

@export var boss_top: float = 40.0            # 부장님 상한 Y
@export var boss_bottom: float = 360.0        # 부장님 하한 Y

@export var dodges_to_win: int = 6            # 이만큼 피하면 승리
@export var hits_to_lose: int = 3             # 이만큼 맞으면 패배

# 기영이 히트박스, Player 스크립트 참고해서 적당히 조정 가능
@export var player_hitbox_size: Vector2 = Vector2(24, 32)

@export var nagging_texts: Array[String] = [
	"보고서 다 했어요?",
	"야근 좀 더 할 수 있지?",
	"내가 젊었을 땐 말이야…",
	"커피는 타왔나요?",
	"요즘 MZ는 말이야",
	"그건 내가 다 해봤어"
]

@onready var player: CharacterBody2D = $Giiyoung   # Player.gd 붙어있는 기영이
@onready var player_sprite: AnimatedSprite2D = $Giiyoung/AnimatedSprite2D

@onready var boss: Node2D = $Boss
@onready var nags_root: Control = $Nags
@onready var shoot_timer: Timer = $ShootInterval

var boss_dir: int = 1      # 1: 아래, -1: 위
var dodged_count: int = 0
var hit_count: int = 0
var game_over: bool = false


func _ready() -> void:
	randomize()

	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()


func _process(delta: float) -> void:
	if game_over:
		return

	# 기영이 이동/애니메이션은 Player.gd에서 처리하므로 여기서 건드리지 않음
	_update_boss(delta)
	_update_projectiles(delta)
	_check_end_conditions()


# ───────────────── 부장님 움직임 ─────────────────

func _update_boss(delta: float) -> void:
	var pos: Vector2 = boss.position
	pos.y += boss_speed * boss_dir * delta

	if pos.y <= boss_top:
		pos.y = boss_top
		boss_dir = 1
	elif pos.y >= boss_bottom:
		pos.y = boss_bottom
		boss_dir = -1

	boss.position = pos


# ───────────────── 잔소리 투사체 로직 ─────────────────

func _update_projectiles(delta: float) -> void:
	var player_rect: Rect2 = _get_player_rect()

	for child in nags_root.get_children():
		if not (child is Label):
			continue
		var label := child as Label

		var gp: Vector2 = label.global_position
		gp.x -= projectile_speed * delta
		label.global_position = gp

		# 화면 왼쪽을 벗어나면 '피한 것'으로 처리
		if gp.x + label.size.x < 0.0:
			dodged_count += 1
			label.queue_free()
			continue

		# 충돌 체크
		var rect := Rect2(label.global_position, label.size)
		if rect.intersects(player_rect):
			hit_count += 1
			label.queue_free()
			print("[DodgeGame] HIT! hits=", hit_count)
			continue


func _on_shoot_timer_timeout() -> void:
	if game_over:
		return
	_spawn_nagging()


func _spawn_nagging() -> void:
	var label := Label.new()
	label.text = _pick_nagging_text()
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(1, 1, 0))
	label.add_theme_font_size_override("font_size", 18)

	nags_root.add_child(label)

	# 부장님 위치 기준으로 살짝 왼쪽에서 생성
	var start_pos: Vector2 = boss.global_position
	start_pos.x -= 40.0
	label.global_position = start_pos


# ───────────────── 게임 종료 판정 ─────────────────

func _check_end_conditions() -> void:
	if game_over:
		return

	if hit_count >= hits_to_lose:
		_end_game(false)
	elif dodged_count >= dodges_to_win:
		_end_game(true)


func _end_game(success: bool) -> void:
	if game_over:
		return
	game_over = true

	shoot_timer.stop()

	for child in nags_root.get_children():
		child.queue_free()

	print("[DodgeGame] Game Over. success=", success,
		" dodged=", dodged_count, " hits=", hit_count)

	minigame_finished.emit(success)


# ───────────────── 유틸 함수들 ─────────────────

# Player 스크립트를 고려한 기영이 판정박스
func _get_player_rect() -> Rect2:
	# 중심은 AnimatedSprite2D 기준
	var center: Vector2 = player_sprite.global_position
	var size: Vector2 = player_hitbox_size
	var top_left: Vector2 = center - size * 0.5
	return Rect2(top_left, size)


func _pick_nagging_text() -> String:
	if nagging_texts.is_empty():
		return "……"
	var idx: int = randi() % nagging_texts.size()
	return nagging_texts[idx]
