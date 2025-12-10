extends Node

#add signal : junsang
signal add_coffee(cnt : int)
signal add_cream(cnt : int)
signal add_sugar(cnt : int)


var stage_level: int
const MAX_STAGE: int = 5

var main_time_scale: float
var is_playing_minigame: bool

var is_coffee_ready: bool

var coffee_count: int = 0
var prim_count: int = 0
var sugar_count: int = 0

func _ready() -> void:
	stage_level = 1
	main_time_scale = 1.0 # normal time scale for the main scene
	is_playing_minigame = false
	is_coffee_ready = false

func reset_states():
	main_time_scale = 1.0
	
	is_playing_minigame = false
	
	is_coffee_ready = false
	
	coffee_count = 0
	prim_count = 0
	sugar_count = 0

func reset_stage_to_start():
	stage_level = 1
	reset_states()
	
func go_to_next_stage():
	stage_level += 1
	reset_states()
	
	if stage_level > MAX_STAGE:
		stage_level = MAX_STAGE

func reset_global_events():
	BubbleManager.clearAllbubble()
	#Dialogic.clear()
	Dialogic.end_timeline()
