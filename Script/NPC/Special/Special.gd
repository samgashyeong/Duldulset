extends CharacterBody2D

class_name Special

@onready var tilemap = $"../../../Map/WalkableArea"
@onready var dialogue_handler = $"../../../DialogueHandler"

var spawn_position: Vector2
var is_returned: bool
var current_path: Array[Vector2]
var moving_direction: Vector2
var state: States

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 80

var total_frame = []


var dialogue
var character
@onready var bubble_position = $BubblePosition

var dialogue_path
var character_path


func _ready() -> void:
	spawn_position = Vector2(79, 46)
	
	character = load(character_path)
	
	
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	animated_sprite.play("down")
	animated_sprite.stop()
	
	moving_direction = Vector2.ZERO
	
	move_towards(spawn_position+Vector2(0, -4*32))
	state = States.GOING
	
	dialogue_handler.effectHealth.connect("_on_dialogue_handler_dialogue_finished")

func do_dialogue():
	# make sure character is loaded
	dialogue = Dialogic.start(dialogue_path)
	
	dialogue.register_character(character, bubble_position)
	
func despawn():
	queue_free()
	

func _physics_process(delta: float) -> void:
	if state == States.FINISHED:
		despawn()
		return

	if state == States.WAITING or state == States.TALKING:
		return
		
	if state == States.GOING and current_path.is_empty():
		state = States.WAITING
		current_path.clear()
		moving_direction = Vector2.ZERO
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
	state = States.RETURNING
	

func _process(delta: float) -> void:
	if state == States.WAITING:
		do_dialogue()
		state = States.TALKING
		
	handle_animation()

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
	if tilemap.is_point_walkable(target_position):
		current_path = get_path_to_target(target_position)
		

func _on_dialogue_handler_dialogue_finished(dummy: int):
	print("dialogue finished!")
	state = States.RETURNING
	

enum States{
	GOING,
	WAITING,
	TALKING,
	RETURNING,
	FINISHED
}
