extends CharacterBody2D

class_name Boss

@onready var tilemap = $"../../../Map/WalkableArea"
@onready var player: Player = $"../../../Giiyoung"

var spawn_position: Vector2
var is_returned: bool
var current_path: Array[Vector2]
var moving_direction: Vector2
var state: States
var can_talk: bool

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 100

var total_frame = []

signal boss_talking()

func _ready() -> void:
	spawn_position = Vector2(80, 48)
	
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("down")
	animated_sprite.stop()
	
	moving_direction = Vector2.ZERO
	
	move_towards(player.global_position)
	state = States.CHASING
	
	can_talk = true

	
func despawn():
	queue_free()
	

func _physics_process(delta: float) -> void:
	if state == States.FINISHED:
		despawn()
		return

	if state == States.WAITING:
		return
		
	if state == States.CHASING and current_path.is_empty():
		move_towards(player.global_position)
		return
	
	if state == States.RETURNING and global_position == spawn_position:
		is_returned = true
		state = States.FINISHED
		return
	else:
		is_returned = false
		
	var next_to_move = current_path.front()
	moving_direction = (next_to_move - global_position).normalized()
	global_position = global_position.move_toward(next_to_move, delta * GameData.main_time_scale * speed)
	
	if global_position == next_to_move:
		current_path.pop_front()

func return_to_spawn():
	print("return to spawn point")
	#current_path = get_path_to_target(spawn_position)
	move_towards(spawn_position)
	can_talk = false
	state = States.RETURNING
	

func _process(delta: float) -> void:
	handle_animation()

func handle_animation():
	if state == States.WAITING or state == States.FINISHED:
		animated_sprite.stop()
		return
	
	if current_path.is_empty():
		animated_sprite.stop()
		return
		
	if moving_direction.x == -1 and moving_direction.y == 0:
		animated_sprite.play("left")
	elif moving_direction.x == 1 and moving_direction.y == 0:
		animated_sprite.play("right")
	elif moving_direction.x == 0 and moving_direction.y == -1:
		animated_sprite.play("up")
	elif moving_direction.x == 0 and moving_direction.y == 1:
		animated_sprite.play("down")
	else:
		animated_sprite.stop()
	
func get_path_to_target(target_position):
	var tile_path = tilemap.astar.get_id_path(
			tilemap.local_to_map(global_position),
			tilemap.local_to_map(target_position)
		).slice(1)
		
	var world_path: Array[Vector2]
		
	for tile_position in tile_path:
		var world_position = tilemap.map_to_local(tile_position)
		world_path.append(world_position)
		
	return world_path

func move_towards(target_position):
	var near_position = get_possible_position_near(target_position)
	current_path = get_path_to_target(near_position)
	#if tilemap.is_point_walkable(target_position):
	#	current_path = get_path_to_target(target_position)

func get_possible_position_near(target_position):
	var waypoint: Vector2
	for dx in range(-64, 64, 32):
		for dy in range(-64, 64, 32):
			waypoint = target_position + Vector2(dx, dy)
			if tilemap.is_point_walkable(waypoint):
				return waypoint
	return null

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if can_talk and GameData.is_playing_minigame == false:
			state = States.WAITING
			
			current_path.clear()
			moving_direction = Vector2.ZERO
			
			GameData.is_playing_minigame = true
			print("boss wants to talk with you!")
			boss_talking.emit()

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		if can_talk:
			state = States.CHASING
			print("boss still chases you!")
	

enum States{
	CHASING,
	WAITING,
	RETURNING,
	FINISHED
}
