extends Control
class_name FixingPrinterMinigame

signal minigame_finished(success: bool)

@export var max_hp: int = 10
@export var cursor_speed: float = 400.0
@export var perfect_width_px: int = 40    # 가운데 perfect 구간 전체 폭
@export var good_width_px: int = 152      # 그 다음 good 구간 전체 폭
@export var bad_width_px: int = 304       # 전체 bad 구간(이동 범위) 폭
@export var hit_stop_time: float = 0.5


@onready var timing_bar: Node2D               = $TimingBar
@onready var bad_area: Sprite2D               = $TimingBar/BadArea
@onready var good_area: Sprite2D              = $TimingBar/GoodArea     # 시각용
@onready var perfect_area: Sprite2D           = $TimingBar/PerfectArea  # 시각용
@onready var cursor: Node2D                   = $TimingBar/Cursor
@onready var hit_rect: Sprite2D              = $TimingBar/Cursor/Hitbox
@onready var printer: AnimatedSprite2D = $Printer
@onready var explosion: AnimatedSprite2D = $Explosion
@onready var hit_sound: AudioStreamPlayer2D   = $AudioStreamPlayer2D

var current_hp: int = 0
var cursor_dir: int = 1            # 1: 오른쪽, -1: 왼쪽
var game_finished: bool = false

var left_limit: float = 0.0        # 이동 최소 X(전역 좌표)
var right_limit: float = 0.0       # 이동 최대 X(전역 좌표)
var cursor_y: float = 0.0          # 커서 Y 고정값(전역 좌표)

var pause_timer: float = 0.0       # 클릭 후 일시정지 타이머


func _ready() -> void:
	current_hp = max_hp

	_compute_move_limits()

	# 커서 시작 위치: BadArea 왼쪽 끝 위쪽에 맞추기
	cursor_y = cursor.global_position.y
	cursor.global_position.x = left_limit
	cursor.global_position.y = cursor_y
	
		# 폭발 기본 상태
	if explosion:
		explosion.visible = false
		explosion.stop()

func _process(delta: float) -> void:
	if game_finished:
		return

	# 클릭 후 잠시 멈춤
	if pause_timer > 0.0:
		pause_timer -= delta
		return

	_move_cursor(delta)


func _input(event: InputEvent) -> void:
	if game_finished:
		return

	if event.is_action_pressed("click") or event.is_action_pressed("inter_action") or event.is_action_pressed("interact"):
		if hit_sound:
			hit_sound.play()
		_handle_interact()

func _move_cursor(delta: float) -> void:
	var x: float = cursor.global_position.x
	x += cursor_speed * cursor_dir * delta

	if x <= left_limit:
		x = left_limit
		cursor_dir = 1
	elif x >= right_limit:
		x = right_limit
		cursor_dir = -1

	cursor.global_position = Vector2(x, cursor_y)


func _handle_interact() -> void:
	# 잠깐 멈춤
	pause_timer = hit_stop_time

	# HitRect 중심 X (전역)
	var hit_center_x: float = hit_rect.global_position.x

	# 바 중앙 X (BadArea 기준)
	var bad_rect: Rect2 = _get_sprite_global_rect(bad_area)
	var bar_center_x: float = bad_rect.position.x + bad_rect.size.x * 0.5

	var dx: float = abs(hit_center_x - bar_center_x)  # 바 중앙에서 얼마나 떨어져 있는지(px)

	var half_perfect: float = float(perfect_width_px) * 0.5        # PERFECT 반폭(=20px)
	var half_good: float = float(good_width_px) * 0.5        # GOOD 전체를 양쪽으로 나누었을 때 한쪽 폭(=76px)

	var damage: int = 0
	var label: String = "BAD"

	if dx <= half_perfect:
		damage = 4
		label = "PERFECT"
	elif dx <= half_good:
		damage = 2
		label = "GOOD"
	else:
		damage = 0
		label = "BAD"

	print(
		"[FixingPrinter] click: ", label,
		", dx=", dx,
		", damage=", damage,
		", hp(before)=", current_hp, "/", max_hp
	)

	if damage > 0:
		current_hp -= damage

		if current_hp == 0:
			print("[FixingPrinter] CLEARED 정확히 10데미지! hp=", current_hp)
			_on_cleared_success()
		elif current_hp < 0:
			print("[FixingPrinter] TOO STRONG! 기계 부서짐. hp=", current_hp)
			_on_broken_fail()
		else:
			print("[FixingPrinter] hp(after)=", current_hp, "/", max_hp)


func _on_cleared_success() -> void:
	$Printer/Smoke.pause()
	$Printer/Smoke2.pause()
	if game_finished:
		return
	game_finished = true
	minigame_finished.emit(true)   # 성공

func _on_broken_fail() -> void:
	if game_finished:
		return
	game_finished = true

	# 더 이상 안 움직이게 완전 정지
	#pause_timer = 9999.0

	if explosion:
		# 폭발 노드 보이게 + 재생
		explosion.visible = true
		explosion.play("Explosion")   # 애니 이름은 에디터에서 지정한 이름
		printer.set_frame(1)
		printer.pause()
		

		# 애니 끝나면 한 번만 콜백
		explosion.animation_finished.connect(
			_on_explosion_finished,
			CONNECT_ONE_SHOT
		)
	else:
		# 폭발 없으면 바로 실패 처리
		_on_explosion_finished()
		
func _on_explosion_finished() -> void:
	# 여기서 MiniGameManager에게 "실패" 알리기
	minigame_finished.emit(false)




# ─────────────────────
#  헬퍼 함수들
# ─────────────────────

func _compute_move_limits() -> void:
	# 바의 중앙은 PerfectArea의 중심으로 본다
	var bar_center_x: float = perfect_area.global_position.x

	# bad 영역 전체 폭의 절반(= 한쪽 방향 길이)
	var half_bad: float = float(bad_width_px) * 0.5

	left_limit = bar_center_x - half_bad
	right_limit = bar_center_x + half_bad

	print("[FixingPrinter] move range(from constants): ", left_limit, " ~ ", right_limit)
	print("bar_center : ", bar_center_x)



func _get_sprite_global_rect(s: Sprite2D) -> Rect2:
	if s.texture == null:
		return Rect2(s.global_position, Vector2.ZERO)

	var tex_size: Vector2 = s.texture.get_size() * s.scale
	var top_left: Vector2 = s.global_position - tex_size * 0.5
	return Rect2(top_left, tex_size)
