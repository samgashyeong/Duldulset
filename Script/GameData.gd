extends Node

var stage_level: int
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
