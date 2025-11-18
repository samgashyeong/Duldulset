extends Node2D 

# 커피, 프림, 설 
const CoffeeButtonClass: Script = preload("res://Script/CoffeeSc_dongwoo/Coffee_button.gd")
const COFFEEBEAN_SCENE = preload("res://Scene/coffee_dongwoo/Coffeebean.tscn")
const BEAN_COUNT = 3 
const PrimButtonClass: Script = preload("res://Script/CoffeeSc_dongwoo/PrimButton.gd") 
const PRIM_SCENE = preload("res://Scene/coffee_dongwoo/Prim.tscn") 
const PRIM_COUNT = 3
const SugarButtonClass: Script = preload("res://Script/CoffeeSc_dongwoo/SugarButton.gd") 
const SUGAR_SCENE = preload("res://Scene/coffee_dongwoo/Sugar.tscn")
const SUGAR_FOLLOWER_SCENE = preload("res://Scene/coffee_dongwoo/SugarFollower.tscn")

# 물병
const WaterbottleClass: Script = preload("res://Script/CoffeeSc_dongwoo/Waterbottle.gd")
const WATERBOTTLE_FOLLOWER_SCENE = preload("res://Scene/coffee_dongwoo/WaterbottleFollower.tscn") # ⚠️ 경로 확인!
const BACKTO_SCENE_PATH = "res://Scene/coffee_dongwoo/Backto.tscn" # ⚠️ 경로 확인!

# 상태 추적 변수 
var current_sugar_follower: Node = null
var current_water_follower: Node = null
var is_waterbottle_unlocked = false 

# 씬 노드 
@onready var cup1: Node2D = $Cup3
@onready var cup2: Node2D = $Cup4
#@onready var cup3: Node2D = $Cup3
#@onready var cup4: Node2D = $Cup4
@onready var water_bottle_node: Waterbottle = $Waterbottle
@onready var fade_player: AnimationPlayer = $FadePlayer
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var scene_transition_timer: Timer = $SceneTransitionTimer


func _ready():
	#  원두 버튼 연결 
	var coffee_button = $CoffeeButton 
	if coffee_button and coffee_button is CoffeeButtonClass:
		coffee_button.requested_coffeebean_spawn.connect(_on_requested_coffeebean_spawn)
	
	#  프림 버튼 연결 
	var prim_button = $PrimButton 
	if prim_button and prim_button is PrimButtonClass:
		prim_button.requested_prim_spawn.connect(_on_requested_prim_spawn)
	
	#  설탕 버튼 연결 
	var sugar_button = $SugarButton
	if sugar_button and sugar_button is SugarButtonClass:
		sugar_button.requested_sugar_spawn.connect(_on_requested_sugar_spawn)

	#  물병 버튼 연결 
	if water_bottle_node and water_bottle_node is WaterbottleClass:
		water_bottle_node.picked_up.connect(_on_waterbottle_picked_up)
	
	#  씬 전환 타이머 연결 
	if scene_transition_timer:
		scene_transition_timer.timeout.connect(_on_scene_transition_timer_timeout)

	#  초기 상태 설정 
	if cup2:
		cup2.visible = false
	if water_bottle_node:
		water_bottle_node.lock()

# 물병 잠금 해제
func _unlock_waterbottle():
	if is_waterbottle_unlocked:
		return
	
	is_waterbottle_unlocked = true
	if water_bottle_node:
		water_bottle_node.unlock()

# 물병 집기
func _on_waterbottle_picked_up():
	if is_instance_valid(current_sugar_follower) or is_instance_valid(current_water_follower):
		return

	if cup1: cup1.visible = false
	if cup2: cup2.visible = true
	
	water_bottle_node.hide_on_desk()
	
	var follower = WATERBOTTLE_FOLLOWER_SCENE.instantiate()
	current_water_follower = follower
	
	if cup2:
		follower.cup_position = cup2.global_position
	
	add_child(follower)
	
	follower.started_pouring.connect(_on_started_pouring)

# 물 붓기 시작
func _on_started_pouring():
	if scene_transition_timer:
		scene_transition_timer.start()

func _on_scene_transition_timer_timeout():
	if fade_player and fade_player.has_animation("FadeOut"):
		fade_player.animation_finished.connect(_on_fade_animation_finished)
		fade_overlay.visible = true
		fade_player.play("FadeOut")
		print("시작합")

func _on_fade_animation_finished(_anim_name):
	get_tree().change_scene_to_file(BACKTO_SCENE_PATH)

# 설탕 생성 
func _on_requested_sugar_spawn():
	_unlock_waterbottle() 
	
	if is_instance_valid(current_sugar_follower) or is_instance_valid(current_water_follower):
		return 
	var follower = SUGAR_FOLLOWER_SCENE.instantiate()
	current_sugar_follower = follower
	add_child(follower)
	follower.placed.connect(_on_sugar_placed)

# 설탕 배치
func _on_sugar_placed(spawn_position: Vector2):
	current_sugar_follower = null
	var sugar = SUGAR_SCENE.instantiate()
	add_child(sugar)
	sugar.global_position = spawn_position

# 원두 생성 
func _on_requested_coffeebean_spawn(button_position: Vector2):
	_unlock_waterbottle() 
	
	# 갯수 조정
	# var num_to_spawn = randi_range(1, BEAN_COUNT)
	var num_to_spawn = 10
	
	for i in range(num_to_spawn):
		var bean = COFFEEBEAN_SCENE.instantiate()
		add_child(bean)
		var spawn_x = button_position.x + randf_range(-15.0, 15.0) 
		var spawn_y = button_position.y + 40.0
		bean.global_position = Vector2(spawn_x, spawn_y)
		if bean is RigidBody2D:
			bean.rotation = randf_range(0, TAU) 

# 프림 생성 
func _on_requested_prim_spawn(button_position: Vector2):
	_unlock_waterbottle() 
	
	var num_to_spawn = randi_range(1, PRIM_COUNT)
	
	for i in range(num_to_spawn):
		var prim = PRIM_SCENE.instantiate() 
		add_child(prim)
		var spawn_x = button_position.x + randf_range(-15.0, 15.0) 
		var spawn_y = button_position.y + 40.0
		prim.global_position = Vector2(spawn_x, spawn_y)
		if prim is RigidBody2D:
			prim.rotation = randf_range(0, TAU)
