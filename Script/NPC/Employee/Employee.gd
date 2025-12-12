extends CharacterBody2D

class_name Employee

@onready var tilemap = $"../../../Map/WalkableArea"
@onready var player: Player = $"../../../Giiyoung"

@onready var spilled_waters = $"../../../SpilledWater"
var spilled_water_scene: PackedScene = preload("res://Scene/Map/Object/Interactable/SpilledWater.tscn")
@onready var minigame_manager = $"../../../MinigameScreen/MiniGameManager"
@onready var task_list: DailyTask = $"../../../GameSystem/TaskList"

var working_position
var is_returned = true
var current_path: Array[Vector2]
var return_path: Array[Vector2]
var moving_direction: Vector2

var state: States
var coffee_state: CoffeeStates
var staff_name: Type.StaffName
var text_box = null
var order_index
var can_interact = false

var coffee_data: Coffee

signal coffe_order_difference(coffee_diff: int, cream_diff: int, sugar_diff: int, staffName : Type.StaffName, orderType: int)

##set Ui signal
signal menu(type:Type.StaffMethod, name : Type.StaffName)
signal addLog(type : Type.LOG, staffName : Type.StaffName)
signal addBubble(textBox : Control)
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
	if global_position == working_position:
		is_returned = true
	else:
		is_returned = false
	
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
		
	var next_to_move = current_path.front()
	moving_direction = (next_to_move - global_position).normalized()
	global_position = global_position.move_toward(next_to_move, delta * GameData.main_time_scale * speed)
	
	if global_position == next_to_move:
		current_path.pop_front()
	
func return_to_desk():
	print("return to desk")	
	var near_position = get_possible_position_near(working_position)
	if near_position == null:
		# just use return path
		current_path = return_path
		print("can't get near_position. use return path.")
		return
		
	var raw_path = get_path_to_target(near_position)
	if raw_path.is_empty():
		# just use return path
		current_path = return_path
		print("can't get proper path. use return path.")
		return
		
	raw_path.append(working_position)
	current_path = get_manhattan_path(raw_path)
	#print(current_path)

func get_possible_position_near(target_position):
	var waypoint: Vector2
	for dx in range(-24, 24, 24):
		for dy in range(-64, 64, 32):
			waypoint = target_position + Vector2(dx, dy)
			if tilemap.is_point_walkable(waypoint):
				return waypoint
	return null


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
		#print(current_path)

func wander(target_position):
	#print("wander")
	#print(target_position)
	move_towards(target_position)
	if !current_path.is_empty():
		state = States.WANDERING
		return_path = current_path.duplicate()
		return_path.reverse()
	
func order_coffee():
	#sound play
	SoundManager.play_order_sound()
	#print("coffee order")
	state = States.WAITING
	coffee_state = CoffeeStates.CALLING
	text_box = BubbleManager.startDialog(global_position, staff_name)
	text_box.angryTimer.timeout.connect(_on_text_box_angry_timer_timeout)
	text_box.orderTimer.timeout.connect(_on_text_box_order_timer_timeout)
	text_box.textToDisPlay(Type.StaffMethod.ORDER)
	
	#set signal
	addBubble.emit(text_box)
	addLog.emit(Type.LOG.ORDER, staff_name)

func _input(event):
	if event.is_action_pressed("interact") and can_interact and state == States.WAITING and !GameData.is_playing_minigame:
		print("talking")
		SoundManager.play_menu_upload_sound()
		if coffee_state == CoffeeStates.CALLING:
			order_index = randi_range(0,2)
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
			coffee_state = CoffeeStates.ORDERING
		
		elif coffee_state == CoffeeStates.ORDERING and GameData.is_coffee_ready:
			text_box.textToDisPlay(Type.StaffMethod.CHECK)
			coffee_state = CoffeeStates.CHECKING
			check_coffee()
			
			#emit signal : junsang
			GameData.add_coffee.emit(0)
			GameData.add_sugar.emit(0)
			GameData.add_cream.emit(0)

func check_coffee():
	var coffee_order = coffee_data.orders[order_index]
	
	var coffee_diff = GameData.coffee_count - coffee_order.coffee
	var cream_diff = GameData.prim_count - coffee_order.cream
	var sugar_diff = GameData.sugar_count - coffee_order.sugar
	var total_diff = coffee_diff + cream_diff + sugar_diff
	print("checking")
	if total_diff <= 3:
		player.update_point(100)
	else:
		player.update_health(-1)
		
	coffe_order_difference.emit(coffee_diff, cream_diff, sugar_diff, staff_name, order_index)
	
	consume_coffee()
	reset_to_normal_states()

func reset_to_normal_states():
	coffee_state = CoffeeStates.CALLING
	state = States.SITTING

func consume_coffee():
	GameData.is_coffee_ready = false
	
	GameData.coffee_count = 0
	GameData.prim_count = 0
	GameData.sugar_count = 0

func _on_text_box_angry_timer_timeout():
	reset_to_normal_states()
	player.update_health(-1)
	
func _on_text_box_order_timer_timeout():
	reset_to_normal_states()
	player.update_health(-1)
	
func spill_water():
	if is_near(global_position, working_position):
		return
		
	var spilled_water = spilled_water_scene.instantiate()
	spilled_water.global_position = global_position
	spilled_water.add_to_group("spilled_waters")
	spilled_water.water_cleaning.connect(_on_spilled_water_water_cleaning)
	spilled_waters.add_child(spilled_water)
	var new_counts = get_tree().get_node_count_in_group("spilled_waters")
	task_list.update_water_clean_task(new_counts)
	

func is_near(point: Vector2, target_point: Vector2):
	var sqr_dist = target_point.distance_squared_to(point)
	if sqr_dist <= 32*32:
		return true
	else:
		return false


func _on_spilled_water_water_cleaning():
	minigame_manager.open_minigame(2)
	
enum States{
	SITTING,
	WANDERING,
	WAITING
}

enum CoffeeStates{
	CALLING,
	ORDERING,
	CHECKING
}
