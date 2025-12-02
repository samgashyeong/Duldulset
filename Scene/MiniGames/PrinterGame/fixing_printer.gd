# 202126868 Minseo Choi
extends Control
class_name FixingPrinter

signal minigame_finished(success: bool)

@export var max_printer_hp: int = 10
@export var cursor_move_speed: float = 400.0        # pixels per second
@export var perfect_zone_width_px: int = 40         # Width of PERFECT zone (pixels)
@export var good_zone_width_px: int = 152           # Width of GOOD zone (pixels)
@export var bad_zone_width_px: int = 304            # Width of BAD zone (pixels)
@export var hit_pause_time_sec: float = 1         # pause time after each click (seconds)

@onready var timing_bar_root: Node2D = $TimingBar
@onready var bad_zone_sprite: Sprite2D = $TimingBar/BadArea
@onready var good_zone_sprite: Sprite2D = $TimingBar/GoodArea
@onready var perfect_zone_sprite: Sprite2D = $TimingBar/PerfectArea
@onready var cursor_node: Node2D = $TimingBar/Cursor
@onready var cursor_hitbox_sprite: Sprite2D = $TimingBar/Cursor/Hitbox
@onready var printer_sprite: AnimatedSprite2D = $Printer
@onready var explosion_sprite: AnimatedSprite2D = $Explosion
@onready var hit_sound: AudioStreamPlayer = $Sounds/HitSound
@onready var success_sound: AudioStreamPlayer = $Sounds/SuccessSound
@onready var explosion_sound: AudioStreamPlayer = $Sounds/ExplosionSound

var current_printer_hp: int = 0
var cursor_move_direction: int = 1              # 1 = right, -1 = left
var is_minigame_finished: bool = false

var cursor_left_limit_x: float = 0.0            # min cursor X in global coordinates
var cursor_right_limit_x: float = 0.0           # max cursor X in global coordinates
var cursor_fixed_y: float = 0.0                 # constant cursor Y in global coordinates

var cursor_pause_timer: float = 0.0             # remaining pause time after a hit (seconds)


func _ready() -> void:
	current_printer_hp = max_printer_hp

	_compute_cursor_move_limits()

	# Set initial cursor position at the left edge of the bar
	cursor_fixed_y = cursor_node.global_position.y
	cursor_node.global_position.x = cursor_left_limit_x
	cursor_node.global_position.y = cursor_fixed_y

	# Initial explosion state
	if explosion_sprite:
		explosion_sprite.visible = false
		explosion_sprite.stop()


# Move cursor or wait during hit pause per frame
func _process(delta: float) -> void:
	if is_minigame_finished:
		return

	# Stop movement for a short time after each click
	if cursor_pause_timer > 0.0:
		cursor_pause_timer -= delta
		return

	_move_cursor(delta)


# Handle click input for timing judgement
func _input(event: InputEvent) -> void:
	if is_minigame_finished:
		return
	
	# If cursor is paused, no input accepted
	if cursor_pause_timer > 0.0:
		return

	# If click or interaction button is pressed
	if event.is_action_pressed("click") or event.is_action_pressed("inter_action") or event.is_action_pressed("interact"):
		if hit_sound:
			hit_sound.play()
		_handle_timing_hit()


# Move the timing cursor left and right between the bar
func _move_cursor(delta: float) -> void:
	var cursor_x: float = cursor_node.global_position.x
	cursor_x += cursor_move_speed * cursor_move_direction * delta

	if cursor_x <= cursor_left_limit_x:
		cursor_x = cursor_left_limit_x
		cursor_move_direction = 1
	elif cursor_x >= cursor_right_limit_x:
		cursor_x = cursor_right_limit_x
		cursor_move_direction = -1

	cursor_node.global_position = Vector2(cursor_x, cursor_fixed_y)


# Evaluate the timing of the hit and apply damage or failure
func _handle_timing_hit() -> void:
	cursor_pause_timer = hit_pause_time_sec

	# Center X of the cursor hitbox
	var hit_center_x: float = cursor_hitbox_sprite.global_position.x

	# Center X of the timing bar
	var bad_rect: Rect2 = _get_sprite_global_rect(bad_zone_sprite)
	var bar_center_x: float = bad_rect.position.x + bad_rect.size.x * 0.5

	var distance_from_center: float = abs(hit_center_x - bar_center_x)

	var half_perfect_width: float = float(perfect_zone_width_px) * 0.5
	var half_good_width: float = float(good_zone_width_px) * 0.5

	var damage_amount: int = 0

	# Calculate damage by delta from timing bar's center
	if distance_from_center <= half_perfect_width:
		damage_amount = 4
		$Printer/SmokeEffect.set_frame(8)
		$Printer/SmokeEffect.pause()
	elif distance_from_center <= half_good_width:
		damage_amount = 2
		$Printer/SmokeEffect2.set_frame(0)
		$Printer/SmokeEffect2.pause()
	else:
		damage_amount = 0

	if damage_amount > 0:
		current_printer_hp -= damage_amount

		if current_printer_hp == 0:
			_on_printer_fixed_success()
		elif current_printer_hp < 0:
			_on_printer_broken_fail()


# Called when the player deals exactly the required damage
func _on_printer_fixed_success() -> void:
	cursor_pause_timer = 9999
	
	if success_sound:
		success_sound.play()
	else:
		_on_success_sound_finished()


# Called when the damage exceeds the remaining HP (printer explodes)
func _on_printer_broken_fail() -> void:
	if is_minigame_finished:
		return

	is_minigame_finished = true

	if explosion_sprite:
		explosion_sprite.visible = true
		explosion_sprite.play("Explosion")
		printer_sprite.set_frame(1)
		printer_sprite.pause()

	if explosion_sound:
		explosion_sound.play()
	else:
		# 사운드가 없으면 바로 실패 처리
		_on_explosion_sound_finished()


# After explosion animation, notify MiniGameManager about failure
func _on_explosion_animation_finished() -> void:
	minigame_finished.emit(false)


# Compute left/right cursor movement limits based on the bar center and configured width
func _compute_cursor_move_limits() -> void:
	var bar_center_x: float = perfect_zone_sprite.global_position.x
	var half_bad_width: float = float(bad_zone_width_px) * 0.5

	cursor_left_limit_x = bar_center_x - half_bad_width
	cursor_right_limit_x = bar_center_x + half_bad_width


# Build a global Rect2 from a Sprite2D (centered on its global position)
func _get_sprite_global_rect(sprite: Sprite2D) -> Rect2:
	if sprite.texture == null:
		return Rect2(sprite.global_position, Vector2.ZERO)

	var texture_size: Vector2 = sprite.texture.get_size() * sprite.scale
	var top_left: Vector2 = sprite.global_position - texture_size * 0.5
	return Rect2(top_left, texture_size)

# If success sound finished, minigame will be also finished with true(success)
func _on_success_sound_finished() -> void:
	minigame_finished.emit(true)


func _on_explosion_sound_finished() -> void:
	minigame_finished.emit(false)
