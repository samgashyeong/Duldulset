class_name WaterbottleFollower extends Area2D

signal started_pouring

const WATER_SCENE = preload("res://Scene/coffee_dongwoo/Water.tscn")

const TILT_DEADZONE = 20.0 
const TILT_MAX_DISTANCE = 150.0
const MAX_TILT_ANGLE = PI / 2.0 
const TILT_THRESHOLD = 0.6 # 물 나오는 각도

var cup_position: Vector2 = Vector2.ZERO
var spout: Marker2D
var spawn_timer: Timer
var has_started_pouring = false

func _ready():
	spout = $Spout
	spawn_timer = $Timer
	spawn_timer.timeout.connect(_on_spawn_water)
	set_process(true)
	set_process_input(false)

func _process(_delta):
	var current_mouse_pos = get_global_mouse_position()
	global_position = current_mouse_pos
	
	var distance_x = current_mouse_pos.x - cup_position.x
	# 컵 위에 있는지 (Y축) 그리고 컵 근처인지 (X축) 확인
	var is_over_cup = global_position.y < cup_position.y and abs(distance_x) < (TILT_MAX_DISTANCE + 50.0)
	
	var target_rotation = 0.0 
	
	# 컵 위에 있을 때만 기울기를 계산
	if is_over_cup:
		if abs(distance_x) > TILT_DEADZONE:
			var tilt_factor = inverse_lerp(TILT_DEADZONE, TILT_MAX_DISTANCE, abs(distance_x))
			target_rotation = clamp(tilt_factor, 0.0, 1.0) * MAX_TILT_ANGLE
			if distance_x > 0:
				target_rotation = -target_rotation

	rotation = lerp(rotation, target_rotation, 0.15) 
	
	# 컵 위에 있고 설정된 각도(THRESHOLD)보다 많이 기울었을 때
	if is_over_cup and abs(rotation) > TILT_THRESHOLD:
		if not has_started_pouring:
			has_started_pouring = true
			started_pouring.emit()
		
		if spawn_timer.is_stopped():
			spawn_timer.start()
	else:
		spawn_timer.stop() 

func _on_spawn_water():
	if not is_instance_valid(spout): return

	var water = WATER_SCENE.instantiate()
	get_parent().add_child(water)
	
	water.global_position = spout.get_global_position()
	var force = Vector2.DOWN.rotated(rotation) * randf_range(50.0, 100.0)
	if water is RigidBody2D:
		water.apply_central_impulse(force)
