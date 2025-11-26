extends CharacterBody2D

class_name Employee

@onready var tilemap = $"../../../Map/WalkableArea"

var current_path: Array[Vector2i]
var moving_direction

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
		
	#if state == States.WANDERING and current_path.is_empty():
		#return_to_desk()
	if current_path.is_empty():
		return
	
	var next_pos_to_move = current_path.front()
	moving_direction = (next_pos_to_move - global_position).normalized
	global_position = global_position.move_toward(next_pos_to_move, delta * GameData.main_time_scale * speed)
	current_path.pop_front()
	
#func return_to_desk():
	
func _process(delta: float) -> void:
	if state == States.SITTING:
		animated_sprite.play("sit")
		return
		
	if state == States.WAITING:
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

func move_towards(target_position):
	if tilemap.is_point_walkable(target_position):
		current_path = tilemap.astar.get_id_path(
			tilemap.local_to_map(global_position),
			tilemap.local_to_map(target_position)
		).slice(1)
		
		print(current_path)

func wander(target_position):
	print("wander")
	print(target_position)
	move_towards(target_position)
	state = States.WANDERING
	
func order_coffee():
	print("coffee order")
	state = States.WAITING
	
enum States{
	SITTING,
	WANDERING,
	WAITING
}
