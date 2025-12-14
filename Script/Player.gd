# 202322111 임상인
# This script is for the Player character.

extends CharacterBody2D

class_name Player

const GAMEOVER_SCENE_PATH = "res://Scene/Screens/GameoverScene.tscn"

# the properties of the Player

# if health <= 0 then game over (losing condition)
var health: int = 100
signal health_changed(new_value, changeValue) # add change Value
@export var max_health = 100

# for movement
@export var base_speed = 80
@export var run_speed = base_speed * 1.5
@export var speed: float = base_speed

var stamina: float = 0 # stamina value is 0-100
var stamina_coefficient: float = 20
signal stamina_changed(new_value, changeValue) # add change Value
@export var max_stamina = 5 * stamina_coefficient
var stamina_unit = 1 * stamina_coefficient # per second (without stamina_coefficient)

var is_running = false

var point: int = 0
signal point_changed(new_value, changeValue) # add change Value


# for animation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var total_frame = []


# It initializes.
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
	
	# only 4-way movement is possible
	if direction.x != 0 and direction.y !=0:
		direction.x = 0
		direction.y = 0
	
	velocity = direction * speed 


# This function does movement handling.
func _physics_process(delta: float) -> void:
	if GameData.is_playing_minigame:
		return
		
	check_running()
	
	# update stamina and speed properly when running or not
	if is_running:
		if stamina > 0:
			speed = run_speed
			stamina = max(stamina - stamina_unit * delta, 0)
			stamina_changed.emit(stamina, -stamina_unit)
		else:
			speed = base_speed
	else:
		speed = base_speed
		stamina = min(stamina + stamina_unit * delta, max_stamina)
		stamina_changed.emit(stamina, stamina_unit)
	
	get_input()
	move_and_slide()
	
	# play sounds properly
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


# This function controls the animation states.
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
	
	if amount > 0:
		SoundManager.play_PointUpUpCh_sound()
	
	if amount < 0:
		SoundManager.play_DamageCh_sound()
	
	if health > 100:
		health = 100
	
	if health <= 0:
		health = 0
		go_to_gameover_scene()	
	
	health_changed.emit(health, amount)

func update_point(amount):
	point += amount
	SoundManager.play_PointUpCh_sound()
	point_changed.emit(point, amount)


func go_to_gameover_scene():
	GameData.reset_stage_to_start()
	GameData.reset_global_events()
	
	SoundManager.play_Gameover_sound()
	get_tree().change_scene_to_file(GAMEOVER_SCENE_PATH)
	
