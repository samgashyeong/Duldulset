extends CharacterBody2D

class_name MinigamePlayer

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var base_speed = 80
@export var speed: float = base_speed

var total_frame = []

var is_running = false

func _ready() -> void:
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("sit")

func get_input():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction.x != 0 and direction.y !=0:
		direction.x = 0
		direction.y = 0
	
	velocity = direction * speed 

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	

	# 움직임소리시작
	if velocity.length() > 0:
		if is_running:
			if SoundManager.get_node("WalkCh").playing:
				SoundManager.get_node("WalkCh").stop()
			if not SoundManager.get_node("RunningCh").playing:
				SoundManager.play_RunningCh_sound()
		else:
			if SoundManager.get_node("RunningCh").playing:
				SoundManager.get_node("RunningCh").stop()

			if not SoundManager.get_node("WalkCh").playing:
				SoundManager.play_WalkCh_sound()
	else:
		if SoundManager.get_node("WalkCh").playing:
			SoundManager.get_node("WalkCh").stop()
		if SoundManager.get_node("RunningCh").playing:
			SoundManager.get_node("RunningCh").stop()
	# 움직임소리끝



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
