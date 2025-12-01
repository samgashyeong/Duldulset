# 202126868 Minseo Choi
extends Control
class_name DodgeGame

# Emitted when the minigame ends (success = true/false)
signal minigame_finished(success: bool)

@export var boss_move_speed: float = 120.0 # (pixels per second)
var boss_move_top_y: float = 40.0
var boss_move_bottom_y: float = 360.0

var nag_shoot_interval: float = 0.8 # (seconds)
var nag_move_speed: float = 400.0 # (pixels per second)

var required_dodges_to_win: int = 6
var max_hits_before_lose: int = 3

var player_hitbox_shape: CollisionShape2D


# Phrases used for nagging (chosen randomly)
@export var nagging_texts: Array[String] = [
	"Stop watching the clock, work.",
	"Your generation gives up too easily.",
	"Company first, your life second.",
	"Ready to work overtime?",
	"Kids these days…",
	"Watch and learn."
]


@onready var player_body: CharacterBody2D = $Giiyoung
@onready var player_sprite: AnimatedSprite2D = $Giiyoung/AnimatedSprite2D
@onready var default_player_hitbox_shape: CollisionShape2D = $Giiyoung/CollisionShape2D

@onready var boss_node: Node2D = $Boss
@onready var nag_label: Label = $Nags
@onready var nag_timer: Timer = $ShootInterval


# Runtime State
var boss_move_direction: int = 1 # (1 = down, -1 = up)
var dodged_nag_count: int = 0
var hit_nag_count: int = 0
var is_game_over: bool = false
var is_nag_active: bool = false


func _ready() -> void:
	randomize()

	# Use the default player hitbox if none was assigned
	if not player_hitbox_shape:
		player_hitbox_shape = default_player_hitbox_shape

	# Apply font to the nag label
	var nag_font := FontFile.new()
	nag_font.font_data = load("res://Font/neodgm (1).ttf")
	nag_label.add_theme_font_override("font", nag_font)
	nag_label.add_theme_font_size_override("font_size", 18)

	nag_label.visible = false
	is_nag_active = false

	nag_timer.wait_time = nag_shoot_interval
	nag_timer.start()

# Update boss movement, nag projectile, and win/lose status every frame
func _process(delta: float) -> void:
	if is_game_over:
		return

	_update_boss_position(delta)
	_update_nag_projectile(delta)
	_check_win_or_lose()

# Update Boss's position for each frame
func _update_boss_position(delta: float) -> void:
	var boss_pos: Vector2 = boss_node.position
	boss_pos.y += boss_move_speed * boss_move_direction * delta

# Limit the boss position & Make boss go up and down
	if boss_pos.y <= boss_move_top_y:
		boss_pos.y = boss_move_top_y
		boss_move_direction = 1
	elif boss_pos.y >= boss_move_bottom_y:
		boss_pos.y = boss_move_bottom_y
		boss_move_direction = -1

	boss_node.position = boss_pos


# Move the nag label and handle dodge/hit detection
func _update_nag_projectile(delta: float) -> void:
	if not is_nag_active:
		return

	var player_hitbox: Rect2 = _get_player_hitbox_rect()
	
	# Move nag label to the left over time
	var nag_global_pos: Vector2 = nag_label.global_position
	nag_global_pos.x -= nag_move_speed * delta
	nag_label.global_position = nag_global_pos

	# Collision check between nag label and player hitbox
	var nag_rect := Rect2(nag_label.global_position, nag_label.size)
	if nag_rect.intersects(player_hitbox):
		hit_nag_count += 1
		_hide_nag_label()
		print("[DodgeGame] HIT! hits = ", hit_nag_count)
		return

	# If the nag label leaves the left side, count as a dodge
	if nag_global_pos.x + nag_label.size.x < 0.0:
		dodged_nag_count += 1
		_hide_nag_label()
		return

# Handle the timer timeout event by spawning a new nag
func _on_shoot_interval_timeout() -> void:
	if is_game_over:
		return
	_spawn_nag_label()


# Create (activate) a new nag label at the boss position
func _spawn_nag_label() -> void:
	# Only one nag can be active at a time in this minigame
	if is_nag_active:
		return
		
	# Pick random text and show the label
	nag_label.text = _pick_random_nag_text()
	nag_label.visible = true
	is_nag_active = true

	# Start slightly to the left of the boss position
	var start_pos: Vector2 = boss_node.global_position - Vector2(40.0, 0.0)
	nag_label.global_position = start_pos

# Hide the nag label and mark it as inactive
func _hide_nag_label() -> void:
	is_nag_active = false
	nag_label.visible = false


# Check if the player has won or lost and finish the game
func _check_win_or_lose() -> void:
	if is_game_over:
		return
		
	# Lose if the player has been hit too many times
	if hit_nag_count >= max_hits_before_lose:
		_finish_minigame(false)
	# Win if the player has dodged enough nags
	elif dodged_nag_count >= required_dodges_to_win:
		_finish_minigame(true)

# Stop the game and emit the result to MiniGameManager
func _finish_minigame(success: bool) -> void:
	if is_game_over:
		return

	is_game_over = true

	nag_timer.stop()
	_hide_nag_label()

	print("[DodgeGame] Game Over. success = ", success,
		" dodged = ", dodged_nag_count, " hits = ", hit_nag_count)

	minigame_finished.emit(success)


# Build the player's hitbox as a Rect2 using CollisionShape2D
func _get_player_hitbox_rect() -> Rect2:
	# If hitbox is missing, use a small default box around the sprite
	if not player_hitbox_shape or not player_hitbox_shape.shape:
		var fallback_size := Vector2(24, 32)
		var sprite_center := player_sprite.global_position
		return Rect2(sprite_center - fallback_size * 0.5, fallback_size)

	var shape := player_hitbox_shape.shape
	var hitbox_size := Vector2.ZERO

	# If player's hitbox shape is RectangleShape2D, set hitbox size as the Rectangle size
	if shape is RectangleShape2D:
		hitbox_size = (shape as RectangleShape2D).size
	else:
		# else, set hitbox size defalut
		hitbox_size = Vector2(24, 32)
		
	# Build a rect centered at the CollisionShape2D position
	var center: Vector2 = player_hitbox_shape.global_position
	var top_left: Vector2 = center - hitbox_size * 0.5
	return Rect2(top_left, hitbox_size)


# Return one random nag text from the list
func _pick_random_nag_text() -> String:
	if nagging_texts.is_empty():
		return "Nagging_texts are empty."
	var index: int = randi() % nagging_texts.size()
	return nagging_texts[index]
