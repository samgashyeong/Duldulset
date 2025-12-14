# 202322111 임상인
# This script is for Boss special NPC.

extends CharacterBody2D

# Define a 'Boss' class
class_name Boss

# for referencing nodes in the MainGameScene
@onready var tilemap = $"../../../Map/WalkableArea"

@onready var player: Player = $"../../../Giiyoung"


# for pathfinding
var spawn_position: Vector2
var is_returned: bool
var current_path: Array[Vector2]


# for interactions and state management
var state: States
var can_talk: bool


# for movement and animation
@export var speed = 100
var moving_direction: Vector2
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var total_frame = []


# for other nodes to be noticed when the boss is talking to the Player
signal boss_talking()


# This function initializes NPC state.
func _ready() -> void:
	# spawn position is below the door
	spawn_position = Vector2(80, 48)
	
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("down")
	animated_sprite.stop()
	moving_direction = Vector2.ZERO
	
	# start to chase the Player
	move_towards(player.global_position)
	state = States.CHASING
	can_talk = true


# This function despawns the Boss.
func despawn():
	queue_free()


# This function does movement handling.
func _physics_process(delta: float) -> void:
	# if the Boss has finished the task, despawns
	if state == States.FINISHED:
		despawn()
		return
	
	# check if the Boss is in non-moving state
	if state == States.WAITING:
		return
	
	# check if the Boss is in CHASING state but the current path is empty
	if state == States.CHASING and current_path.is_empty():
		# chase the Player again
		move_towards(player.global_position)
		return
	
	# check if the Boss is in RETURNING state and reached to the spawn position
	if state == States.RETURNING and global_position == spawn_position:
		# update is_returned and change state
		is_returned = true
		state = States.FINISHED
		return
	else:
		# update is_returned
		is_returned = false
	
	# movement handling logic
	var next_to_move = current_path.front()
	moving_direction = (next_to_move - global_position).normalized()
	global_position = global_position.move_toward(next_to_move, delta * GameData.main_time_scale * speed)
	
	# if reached to waypoint in the current_path, update it
	if global_position == next_to_move:
		current_path.pop_front()

# This function makes the Boss return to the spawn position.
func return_to_spawn():
	print("return to spawn point")
	move_towards(spawn_position)
	
	# change states
	can_talk = false
	state = States.RETURNING


# This function controls the animation states.
func _process(delta: float) -> void:
	handle_animation()

# This function actually handles the animation states.
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


# This function actually returns a path to the target position in world position.
func get_path_to_target(target_position):
	# get the tile path to the target position by astar pathfinding
	var tile_path = tilemap.astar.get_id_path(
			tilemap.local_to_map(global_position),
			tilemap.local_to_map(target_position)
		).slice(1)
		
	var world_path: Array[Vector2]
	
	# convert the tile path to world path
	for tile_position in tile_path:
		var world_position = tilemap.map_to_local(tile_position)
		world_path.append(world_position)
		
	return world_path
	
# This function manipulates world path and return a path only with non-diagonal movement.
func get_manhattan_path(raw_world_path: Array[Vector2]):
	# if the raw path is empty, no need to manipulate
	if raw_world_path.is_empty():
		return raw_world_path
	
	var manhattan_path: Array[Vector2]
	
	var start = raw_world_path[0]
	
	# check if it is diagonal movement case with current position and the first point of the path
	if !is_equal_approx(global_position.x, start.x) and !is_equal_approx(global_position.y, start.y):
		# add waypoint between current position and the first point of the path
		# so it ensures L-shape movement (non-diagonal)
		var waypoint = Vector2(start.x, global_position.y)
		manhattan_path.append(waypoint)
	
	# then just passes other points of the path
	manhattan_path.append_array(raw_world_path)
	
	# if the path consists of many points, should also check for the last two points of the path
	if manhattan_path.size() >= 2:
		var last_grid_point = manhattan_path[-2]
		var dest_point = manhattan_path[-1]
		
		# check if it is diagonal movement case for the last two points of the path
		if !is_equal_approx(last_grid_point.x, dest_point.x) and !is_equal_approx(last_grid_point.y, dest_point.y):
			# add waypoint between the two points
			# so it ensures L-shape movement (non-diagonal)
			var waypoint = Vector2(dest_point.x, last_grid_point.y)
			manhattan_path.insert(-1, waypoint)
	
	# finally, return the manipulated world path
	return manhattan_path


# This function actually gets the path to the target position to move.
func move_towards(target_position):
	# get near position (that is valid in the tile position) of the target position
	var near_position = get_possible_position_near(target_position)
	
	# null case handling
	if near_position == null:
		print("can't get near_position!")
		# just return
		return
	
	# now get proper path using near position
	var raw_path = get_path_to_target(near_position)
	
	# make the path only use L-shape movement
	# and update current path
	current_path = get_manhattan_path(raw_path)


# This function finds possible position in the tilemap near the target position.
func get_possible_position_near(target_position):
	var waypoint: Vector2
	# finds in the vicinity area
	# the logic is 3 level for accurate chasing algorithm
	
	# level 1: check exact the target point first
	waypoint = target_position
	if tilemap.is_point_walkable(waypoint):
		return waypoint
	
	# level 2: check one tile around the target point
	for dx in range(-32, 32, 32):
		for dy in range(-32, 32, 32):
			if dx == 0 and dy == 0:
				continue
				
			waypoint = target_position + Vector2(dx, dy)
			if tilemap.is_point_walkable(waypoint):
				return waypoint
	
	# level 3: check two tiles around the target point
	for dx in range(-64, 64, 32):
		for dy in range(-64, 64, 32):
			if not (dx == -64 or dx == 64 or dy == -64 or dy == 64):
				continue
			
			waypoint = target_position + Vector2(dx, dy)
			if tilemap.is_point_walkable(waypoint):
				return waypoint
	
	# can't find proper point in the tilemap
	return null


func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if can_talk and GameData.is_playing_minigame == false:
			# stop chasing
			state = States.WAITING
			current_path.clear()
			moving_direction = Vector2.ZERO
			
			# do boss dodge minigame by emitting signal
			GameData.is_playing_minigame = true
			print("boss wants to talk with you!")
			boss_talking.emit()

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		if can_talk:
			# chase the Player again
			state = States.CHASING
			print("boss still chases you!")


# States of the Boss
enum States{
	CHASING,
	WAITING,
	RETURNING,
	FINISHED
}
