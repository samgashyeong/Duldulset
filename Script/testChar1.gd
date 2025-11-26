extends Sprite2D

@export var playerType : Type.StaffName
var mouseEnter = false
var newbox = null

# 랜덤 움직임 변수들
var move_timer : Timer
var move_speed = 50.0  # 픽셀/초
var move_range = Vector2(200, 200)  # 움직일 수 있는 범위
var original_position : Vector2
var target_position : Vector2
var is_moving = false
var min_move_time = 1.0  # 최소 움직임 간격
var max_move_time = 4.0  # 최대 움직임 간격

func _ready() -> void:
	original_position = global_position
	target_position = global_position
	
	# 랜덤 움직임 타이머 설정
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.timeout.connect(_on_move_timer_timeout)
	move_timer.one_shot = true
	_start_random_move_timer()
	
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	newbox = BubbleManager.startDialog(global_position, Type.StaffName.JUNSANG)
	newbox.textToDisPlay(Type.StaffMethod.ORDER)

func _process(delta):
	# 목표 위치로 부드럽게 이동
	if is_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		# 목표 위치에 도달했으면 움직임 중지
		if global_position.distance_to(target_position) < 5.0:
			is_moving = false

func _start_random_move_timer():
	var wait_time = randf_range(min_move_time, max_move_time)
	move_timer.start(wait_time)

func _on_move_timer_timeout():
	_move_to_random_position()
	_start_random_move_timer()

func _move_to_random_position():
	# 원래 위치 기준으로 랜덤한 목표 위치 생성
	var random_offset = Vector2(
		randf_range(-move_range.x, move_range.x),
		randf_range(-move_range.y, move_range.y)
	)
	
	target_position = original_position + random_offset
	is_moving = true
	
	print("캐릭터 움직임: ", target_position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inter_action") and mouseEnter:
		##여기에 원래 interActionWithPlayer를 호출하려고 했지만 싱글톤 패턴때문에 고민중임
		print("asdf")
		newbox.textToDisPlay(Type.StaffMethod.START0)


	
func _on_area_2d_2_mouse_entered() -> void:
	mouseEnter = true


func _on_area_2d_2_mouse_exited() -> void:
	mouseEnter = false
