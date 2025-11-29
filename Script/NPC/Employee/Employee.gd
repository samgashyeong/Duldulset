extends CharacterBody2D

class_name Employee

@onready var tilemap = $"../../../Map/WalkableArea"

var working_position
var is_returned = true
var current_path: Array[Vector2]
var moving_direction: Vector2

var state

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 80

var total_frame = []

func _ready() -> void:
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("sit")
	state = States.SITTING
	
	moving_direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if state == States.SITTING or state == States.WAITING:
		return
		
	if state == States.WANDERING and current_path.is_empty():
		if is_returned:
			state = States.SITTING
			current_path.clear()
			moving_direction = Vector2.ZERO
			return
		else:
			return_to_desk()
	
	if global_position == working_position:
		is_returned = true
	else:
		is_returned = false
		
	var next_to_move = current_path.front()
	moving_direction = (next_to_move - global_position).normalized()
	global_position = global_position.move_toward(next_to_move, delta * GameData.main_time_scale * speed)
	
	if global_position == next_to_move:
		current_path.pop_front()
	
func return_to_desk():
	print("return to desk")
	var raw_path = get_path_to_target(working_position)
	raw_path.append(working_position)
	current_path = get_manhattan_path(raw_path)
	print(current_path)
	
func _process(delta: float) -> void:
	if state == States.SITTING:
		animated_sprite.play("sit")
		return
		
	if state == States.WAITING:
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

func get_manhattan_path(raw_world_path: Array[Vector2]):
	if raw_world_path.is_empty():
		return raw_world_path
	
	var manhattan_path: Array[Vector2]
	
	var start = raw_world_path[0]
	if !is_equal_approx(global_position.x, start.x) and !is_equal_approx(global_position.y, start.y):
		var waypoint = Vector2(start.x, global_position.y)
		manhattan_path.append(waypoint)
	manhattan_path.append_array(raw_world_path)
	
	if manhattan_path.size() >= 2:
		var last_grid_point = manhattan_path[-2]
		var dest_point = manhattan_path[-1]
		if !is_equal_approx(last_grid_point.x, dest_point.x) and !is_equal_approx(last_grid_point.y, dest_point.y):
			var waypoint = Vector2(dest_point.x, last_grid_point.y)
			manhattan_path.insert(-1, waypoint)
			
	return manhattan_path
	
func move_towards(target_position):
	if tilemap.is_point_walkable(target_position):
		var raw_path = get_path_to_target(target_position)
		current_path = get_manhattan_path(raw_path)
		print(current_path)

func wander(target_position):
	print("wander")
	print(target_position)
	move_towards(target_position)
	if !current_path.is_empty():
		state = States.WANDERING
	
func order_coffee():
	print("coffee order")
	state = States.WAITING
	
enum States{
	SITTING,
	WANDERING,
	WAITING
}
