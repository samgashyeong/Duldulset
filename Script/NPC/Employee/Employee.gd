# 202322111 임상인
# This script is base script for all the Employee NPCs.

extends CharacterBody2D

# Define a class, because it is used as superclass of all the employees.
class_name Employee

# for referencing nodes in the MainGameScene
@onready var tilemap = $"../../../Map/WalkableArea"

@onready var player: Player = $"../../../Giiyoung"

@onready var spilled_waters = $"../../../SpilledWater"
var spilled_water_scene: PackedScene = preload("res://Scene/Map/Object/Interactable/SpilledWater.tscn")

@onready var minigame_manager = $"../../../MinigameScreen/MiniGameManager"

@onready var task_list: DailyTask = $"../../../GameSystem/TaskList"


# for pathfinding
var working_position: Vector2
var is_returned = true
var current_path: Array[Vector2]
var return_path: Array[Vector2]


# for interactions and state management
var staff_name: Type.StaffName
var can_interact = false
var text_box = null

var state: States
var coffee_state: CoffeeStates
var coffee_data: Coffee
var order_index


# for other nodes to be noticed when coffee checking
signal coffe_order_difference(coffee_diff: int, cream_diff: int, sugar_diff: int, staffName : Type.StaffName, orderType: int)


##set Ui signal
signal menu(type:Type.StaffMethod, name : Type.StaffName)
signal addLog(type : Type.LOG, staffName : Type.StaffName)
signal addBubble(textBox : Control)


# for movement and animation
@export var speed = 80
var moving_direction: Vector2
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var total_frame = []


# This function initializes NPC state.
func _ready() -> void:
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("left"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("right"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("up"))
	total_frame.append(animated_sprite.sprite_frames.get_frame_count("down"))
	
	# default state of employee is sitting on their seat
	animated_sprite.play("sit")
	state = States.SITTING
	moving_direction = Vector2.ZERO


# This function does movement handling.
func _physics_process(delta: float) -> void:
	# check and update is_returned first to prevent unexpected bugs
	if global_position == working_position:
		is_returned = true
	else:
		is_returned = false
	
	# check if Employee is in non-moving state
	if state == States.SITTING or state == States.WAITING:
		return
	
	# check if Employee is wandering but finished movement
	if state == States.WANDERING and current_path.is_empty():
		if is_returned:
			# finished to return, now should change its state
			state = States.SITTING
			current_path.clear()
			moving_direction = Vector2.ZERO
			return
		else:
			# wandered to the target position, now should return to their seat
			return_to_desk()
	
	# movement handling logic
	var next_to_move = current_path.front()
	moving_direction = (next_to_move - global_position).normalized()
	global_position = global_position.move_toward(next_to_move, delta * GameData.main_time_scale * speed)
	
	# if reached to waypoint in the current_path, update it
	if global_position == next_to_move:
		current_path.pop_front()
		

# This function handles the case when NPC should return to their seat.
func return_to_desk():
	# get near position (that is valid in the tile position) of the seat position
	var near_position = get_possible_position_near(working_position)
	
	# if can't get valid near position in the tile position
	if near_position == null:
		# just use return path (backtrace the wandering path)
		current_path = return_path
		print("can't get near_position. use return path.")
		return
	
	# now get proper path using near position
	var raw_path = get_path_to_target(near_position)
	
	# if can't get proper path
	if raw_path.is_empty():
		# just use return path (backtrace the wandering path)
		current_path = return_path
		print("can't get proper path. use return path.")
		return
	
	# add short path to the seat position from the last point of the path
	# (using L-shape movement)
	raw_path.append(working_position)
	current_path = get_manhattan_path(raw_path)


# This function finds possible position in the tilemap near the target position.
func get_possible_position_near(target_position):
	var waypoint: Vector2
	# finds in the vicinity area
	# dy range is bigger than dx range
	# this prevents Employee from moving through the wall when returning 
	for dx in range(-24, 24, 24):
		for dy in range(-64, 64, 32):
			waypoint = target_position + Vector2(dx, dy)
			if tilemap.is_point_walkable(waypoint):
				return waypoint
	return null


# This function controls the animation states.
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
	# move only if the target position is walkable in the tilemap
	if tilemap.is_point_walkable(target_position):
		var raw_path = get_path_to_target(target_position)
		current_path = get_manhattan_path(raw_path)

# This function makes the Employee wanders in the tilemap, to the target position.
func wander(target_position):
	move_towards(target_position)
	
	# if successfully get the wandering path
	if !current_path.is_empty():
		# change its state
		state = States.WANDERING
		
		# update return path for backtrace case when returning after wandering
		return_path = current_path.duplicate()
		return_path.reverse() # return path is basically reversed path when backtracing
		return_path.pop_front() # because the wandering target point becomes the current position when returning
		return_path.push_back(working_position) # should add the seat position, because it's not included in the path


# This function makes Employee order a coffee.
func order_coffee():
	#sound play
	SoundManager.play_order_sound()
	
	# change the states
	state = States.WAITING
	coffee_state = CoffeeStates.CALLING
	
	# start the dialogue
	text_box = BubbleManager.startDialog(global_position, staff_name)
	text_box.angryTimer.timeout.connect(_on_text_box_angry_timer_timeout)
	text_box.orderTimer.timeout.connect(_on_text_box_order_timer_timeout)
	text_box.textToDisPlay(Type.StaffMethod.ORDER)
	
	#set signal
	addBubble.emit(text_box)
	addLog.emit(Type.LOG.ORDER, staff_name)


# This function handles the Player's interaction with Employee.
func _input(event):
	if event.is_action_pressed("interact") and can_interact and state == States.WAITING and !GameData.is_playing_minigame:
		print("talking")
		
		# play sound
		SoundManager.play_menu_upload_sound()
		
		# if coffee state is CALLING
		if coffee_state == CoffeeStates.CALLING:
			# choose random order from the defined coffee orders for the Employee
			order_index = randi_range(0,2)
			
			# handle each case
			match order_index:
				0:
					text_box.textToDisPlay(Type.StaffMethod.START0)
					menu.emit(Type.StaffMethod.START0, staff_name)
				1:
					text_box.textToDisPlay(Type.StaffMethod.START1)
					menu.emit(Type.StaffMethod.START1, staff_name)
				2:
					text_box.textToDisPlay(Type.StaffMethod.START2)
					menu.emit(Type.StaffMethod.START2, staff_name)
			
			# change the coffee state
			coffee_state = CoffeeStates.ORDERING
		
		# if coffee state is ORDERING and the Player made a coffee
		elif coffee_state == CoffeeStates.ORDERING and GameData.is_coffee_ready:
			# change the text and coffee state properly
			text_box.textToDisPlay(Type.StaffMethod.CHECK)
			coffee_state = CoffeeStates.CHECKING
			
			# check and judge the coffee
			check_coffee()
			
			#emit signal : junsang
			GameData.add_coffee.emit(0)
			GameData.add_sugar.emit(0)
			GameData.add_cream.emit(0)

# This function actually checks if the coffee the Player made is correct or not.
func check_coffee():
	# get the coffee order information
	var coffee_order = coffee_data.orders[order_index]
	
	# calculate differences of the coffee recipe
	var coffee_diff = GameData.coffee_count - coffee_order.coffee
	var cream_diff = GameData.prim_count - coffee_order.cream
	var sugar_diff = GameData.sugar_count - coffee_order.sugar
	var total_diff = absi(coffee_diff) + absi(cream_diff) + absi(sugar_diff)
	
	print("checking")
	
	# if the total difference is acceptable
	if total_diff <= 2:
		# give the Player proper rewards
		# the lower the total difference, the better the rewards
		
		var point_to_add = 300 - 100 * (total_diff) 
		var health_to_add = 30 - 10 * (total_diff)
		
		player.update_point(point_to_add)
		player.update_health(health_to_add)
	else:
		# give the Player penalty
		player.update_health(-10)
	
	# emit signal about the coffee order difference information
	coffe_order_difference.emit(coffee_diff, cream_diff, sugar_diff, staff_name, order_index)
	
	# consume the coffee Player made
	consume_coffee()
	# and then reset the states
	reset_to_normal_states()


# This function resets the Employee's states.
func reset_to_normal_states():
	coffee_state = CoffeeStates.CALLING
	state = States.SITTING

# This function is for when Employee consumes the coffee Player made.
func consume_coffee():
	# resets all the information related to the coffee
	GameData.is_coffee_ready = false
	
	GameData.coffee_count = 0
	GameData.prim_count = 0
	GameData.sugar_count = 0


# It handles when the Player does not give coffee to the Employee on time.
func _on_text_box_angry_timer_timeout():
	# reset the states
	reset_to_normal_states()
	# give the Player penalty
	player.update_health(-30)

# It handles when the Player does not accept the coffee order on time.
func _on_text_box_order_timer_timeout():
	# reset the states
	reset_to_normal_states()
	# give the Player penalty
	player.update_health(-10)


# This function makes the Employee spill water.
func spill_water():
	# if current position is too close to the seat, don't spill water
	if is_near(global_position, working_position):
		return
	
	# spill water to the current position, and connect it to the game logic
	var spilled_water = spilled_water_scene.instantiate()
	spilled_water.global_position = global_position
	spilled_water.add_to_group("spilled_waters")
	spilled_water.water_cleaning.connect(_on_spilled_water_water_cleaning)
	spilled_waters.add_child(spilled_water)
	var new_counts = get_tree().get_node_count_in_group("spilled_waters")
	task_list.update_water_clean_task(new_counts)

# This function checks if two points are near (in one tile distance).
func is_near(point: Vector2, target_point: Vector2):
	var sqr_dist = target_point.distance_squared_to(point)
	if sqr_dist <= 32*32:
		return true
	else:
		return false

# It handles when the Player interacts with the water that the Employee spilled.
func _on_spilled_water_water_cleaning():
	# open water cleaning minigame
	minigame_manager.open_minigame(2)


# States of the Employee
enum States{
	SITTING,
	WANDERING,
	WAITING
}

# When Employee is in WAITING state (because of coffee order),
# Needed to subdivide coffee order states
enum CoffeeStates{
	CALLING,
	ORDERING,
	CHECKING
}
