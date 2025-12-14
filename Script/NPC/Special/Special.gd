# 202322111 임상인
# This script is for Special NPCs (excluding Boss).

extends CharacterBody2D

# Define a 'Special' class, because it is used as superclass of Special NPCs.
class_name Special

# for referencing nodes in the MainGameScene
@onready var tilemap = $"../../../Map/WalkableArea"

@onready var dialogue_handler = $"../../../DialogueHandler"


# for pathfinding
var spawn_position: Vector2
var is_returned: bool
var current_path: Array[Vector2]


# for state management
var state: States


# for movement and animation
@export var speed = 80
var moving_direction: Vector2
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var total_frame = []


# for dialogue related things with Dialogic
var dialogue
var character
@onready var bubble_position = $BubblePosition

var dialogue_path
var character_path


# This function initializes NPC state.
func _ready() -> void:
	# spawn position is below the door
	spawn_position = Vector2(80, 48)
	
	character = load(character_path)
	
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("down")
	animated_sprite.stop()
	moving_direction = Vector2.ZERO
	
	# move to the certain position (downward from the door)
	move_towards(spawn_position + Vector2(0, 4*32))
	state = States.GOING
	
	# connect signal to handle dialogue finished event
	dialogue_handler.effectHealth.connect(_on_dialogue_handler_dialogue_finished)


# This function starts special dialogue event using Dialogic.
func do_dialogue():
	# make sure character is loaded
	dialogue = Dialogic.start(dialogue_path)
	
	dialogue.register_character(character, bubble_position)


# This function despawns the Special NPC.
func despawn():
	queue_free()


# This function does movement handling.
func _physics_process(delta: float) -> void:
	# if the Special NPC has finished the task, despawns
	if state == States.FINISHED:
		despawn()
		return
	
	# check if the Special NPC is in non-moving state
	if state == States.WAITING or state == States.TALKING:
		return
	
	# check if the Special NPC is in GOING state but the current path is empty
	if state == States.GOING and current_path.is_empty():
		# update states
		state = States.WAITING
		current_path.clear()
		moving_direction = Vector2.ZERO
		return
	
	# check if the Special NPC is in RETURNING state and reached to the spawn position
	if state == States.RETURNING and global_position == spawn_position:
		# update is_returned and change state
		is_returned = true
		state = States.FINISHED
		return
	else:
		# update is_returned
		is_returned = false
	
	# check if the Special NPC is in RETURNING state and the current path is empty
	if state == States.RETURNING and current_path.is_empty():
		# if reached to the spawn position
		if global_position == spawn_position:
			# update is_returned and change state
			is_returned = true
			state = States.FINISHED
			return
		else:
			# return to spawn position
			return_to_spawn()
	
	# movement handling logic
	var next_to_move = current_path.front()
	moving_direction = (next_to_move - global_position).normalized()
	global_position = global_position.move_toward(next_to_move, delta * GameData.main_time_scale * speed)
	
	# if reached to waypoint in the current_path, update it
	if global_position == next_to_move:
		current_path.pop_front()

# This function makes the Special NPC return to the spawn position.
func return_to_spawn():
	print("return to spawn point")
	move_towards(spawn_position)



func _process(delta: float) -> void:
	if state == States.WAITING:
		do_dialogue()
		state = States.TALKING
		
	handle_animation()

# This function handles the animation states.
func handle_animation():
	if state == States.WAITING or state == States.TALKING or state == States.FINISHED:
		animated_sprite.stop()
		return
	
	if current_path.is_empty():
		animated_sprite.stop()
		return
		
	if moving_direction.x == 0 and moving_direction.y == -1:
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

# This function actually gets the path to the target position to move.
func move_towards(target_position):
	if tilemap.is_point_walkable(target_position):
		# get proper path and update current path
		current_path = get_path_to_target(target_position)


# It handles when the dialogue finished.
func _on_dialogue_handler_dialogue_finished(dummy: int):
	print("dialogue finished!")
	# change state
	state = States.RETURNING


# States of the Special NPC
enum States{
	GOING,
	WAITING,
	TALKING,
	RETURNING,
	FINISHED
}
