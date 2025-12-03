extends CharacterBody2D

class_name Player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# if health <= 0 then game over (losing condition)
var health: int = 5
signal health_changed(new_value, changeValue) # add change Value
@export var max_health = 5

@export var base_speed = 80
@export var run_speed = base_speed * 1.5
@export var speed: float = base_speed

var stamina: float = 5
signal stamina_changed(new_value, changeValue) # add change Value
@export var max_stamina = 5
var stamina_unit = 1 # per second

var is_running = false

var point: int = 0
signal point_changed(new_value, changeValue) # add change Value

var total_frame = []

func _ready() -> void:
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("sit")

func check_running():
	if Input.is_action_pressed("run"):
		is_running = true
	else:
		is_running = false

func get_input():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction.x != 0 and direction.y !=0:
		direction.x = 0
		direction.y = 0
	
	velocity = direction * speed 

func _physics_process(delta: float) -> void:
	if GameData.is_playing_minigame:
		return
		
	check_running()
	
	if is_running:
		if stamina > 0:
			speed = run_speed
			stamina = max(stamina - stamina_unit * delta, 0)
			stamina_changed.emit(stamina, -1)
		else:
			speed = base_speed
	else:
		speed = base_speed
		stamina = min(stamina + stamina_unit * delta, max_stamina)
		stamina_changed.emit(stamina, 1)
	
	get_input()
	move_and_slide()
	
	

func _process(delta: float) -> void:
	if GameData.is_playing_minigame:
		animated_sprite.stop()
		return
		
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

func update_health(amount):
	health += amount
	if(health <= 0):
		health = 0
	health_changed.emit(health, amount)
	
func update_point(amount):
	point += amount
	point_changed.emit(point, amount)
	
