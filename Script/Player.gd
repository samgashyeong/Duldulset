extends CharacterBody2D

class_name Player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# if health <= 0 then game over (losing condition)
var health = 5
@export var max_health = 5

@export var base_speed = 80
@export var run_speed = base_speed * 1.5
@export var speed = base_speed

var stamina = 5
@export var max_stamina = 5
var stamina_unit = 1 # per second

var is_running = false

var point = 0

var total_frame = []

func _ready() -> void:
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("down")

func check_running():
	if Input.is_action_pressed("run"):
		is_running = true
	else:
		is_running = false

func get_input():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed

func _physics_process(delta: float) -> void:
	check_running()
	
	if is_running:
		if stamina > 0:
			speed = run_speed
			stamina = max(stamina - stamina_unit * delta, 0)
	else:
		speed = base_speed
		stamina = min(stamina + stamina_unit * delta, max_stamina)
	
	get_input()
	move_and_slide()
	
	if(health <= 0):
		health = 0
		get_tree().paused = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		animated_sprite.frame = (animated_sprite.frame + 1) % total_frame[0]
	elif Input.is_action_just_pressed("ui_right"):
		animated_sprite.frame = (animated_sprite.frame + 1) % total_frame[1]
	elif Input.is_action_just_pressed("ui_up"):
		animated_sprite.frame = (animated_sprite.frame + 1) % total_frame[2]
	elif Input.is_action_just_pressed("ui_down"):
		animated_sprite.frame = (animated_sprite.frame + 1) % total_frame[3]
		
	if Input.is_action_pressed("ui_left"):
		animated_sprite.play("left")
	elif Input.is_action_pressed("ui_right"):
		animated_sprite.play("right")
	elif Input.is_action_pressed("ui_up"):
		animated_sprite.play("up")
	elif Input.is_action_pressed("ui_down"):
		animated_sprite.play("down")
	else:
		animated_sprite.stop()
