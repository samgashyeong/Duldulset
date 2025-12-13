#202221035 현동우
class_name WaterbottleFollower extends Area2D

signal started_pouring

const WATER_SCENE = preload("res://Scene/coffee_dongwoo/Water.tscn")

const TILT_DEADZONE = 20.0 
const TILT_MAX_DISTANCE = 150.0
const MAX_TILT_ANGLE = PI / 2.0 
const TILT_THRESHOLD = 0.6 # 물 나오는 각도 (water exit angle)

var cup_position: Vector2 = Vector2.ZERO #컵위치변수(variance of cup position)
var spout: Marker2D # 물이 나오는 위치 (Spout Marker2D reference)
var spawn_timer: Timer # 물 생성 타이머 (Water spawn Timer reference)
var has_started_pouring = false # 물 붓기 시작 여부 플래그 (Flag if pouring has started)

# 초기화: 스포트 및 타이머 연결, 프로세스 활성화 (Initialization: Connect spout/timer, enable processing)
func _ready():
	spout = $Spout
	spawn_timer = $Timer
	spawn_timer.timeout.connect(_on_spawn_water)
	set_process(true)
	set_process_input(false)

# 실시간 물병 위치 업데이트 및 기울임 계산 (Real-time update of bottle position and tilt calculation)
func _process(_delta):
	var current_mouse_pos = get_global_mouse_position()
	global_position = current_mouse_pos
	
	var distance_x = current_mouse_pos.x - cup_position.x
	# 물병이 컵 위에 있는지 확인 (Check if the bottle is positioned over the cup)
	var is_over_cup = global_position.y < cup_position.y and abs(distance_x) < (TILT_MAX_DISTANCE + 50.0)
	
	var target_rotation = 0.0 
	
	# 컵 위에 있을 때 마우스-컵 거리에 따라 목표 기울임 각도 계산 (Calculate target tilt based on mouse-cup distance when over the cup)
	if is_over_cup:
		if abs(distance_x) > TILT_DEADZONE:
			var tilt_factor = inverse_lerp(TILT_DEADZONE, TILT_MAX_DISTANCE, abs(distance_x))
			target_rotation = clamp(tilt_factor, 0.0, 1.0) * MAX_TILT_ANGLE
			if distance_x > 0:
				target_rotation = -target_rotation

	rotation = lerp(rotation, target_rotation, 0.15) 
	
	# 물 붓기 시작 조건 확인 및 타이머 제어 (Check pouring start condition and control the timer)
	if is_over_cup and abs(rotation) > TILT_THRESHOLD:
		# 물 붓기 시작 신호 최초 발사 (Emit pouring start signal only once)
		if not has_started_pouring:
			has_started_pouring = true
			started_pouring.emit()
		# 물 생성 타이머 시작 (Start water spawn timer)
		if spawn_timer.is_stopped():
			spawn_timer.start()
	else:
		spawn_timer.stop() 

# 타이머 만료 시 물 객체 생성 및 물리력 적용 (Spawn water object and apply physics force when timer expires)
func _on_spawn_water():
	if not is_instance_valid(spout): return

	var water = WATER_SCENE.instantiate()
	get_parent().add_child(water)
	
	water.global_position = spout.get_global_position()
	var force = Vector2.DOWN.rotated(rotation) * randf_range(50.0, 100.0)
	if water is RigidBody2D:
		water.apply_central_impulse(force)
