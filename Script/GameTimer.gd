extends Node

class_name GameTimer

var current_time: float = 0 # seconds in real time (for entire stage timer).
var unit_timer_time: float = 0 # seconds in real time (for unit time passed timer).
var one_hour_timer_time: float = 0 # seconds in real time (for one hour passed timer).
@export var max_time: float = 270 # seconds in real time. 9 hours in game time.
var seconds_per_unit_time: float = max_time * 1/9 * 1/60 # seconds per minutes in game time.
var seconds_per_one_hour: float = max_time * 1/9

# var epsilon = 0.005

signal timeout() # time over
signal unit_time_passed() # one game minute passed
signal one_hour_passed() # one game hour passed

func _ready():
	print(seconds_per_unit_time)
	
func _process(delta: float) -> void:
	current_time = min(current_time + 1 * delta * GameData.main_time_scale, max_time)
	unit_timer_time = min(unit_timer_time + 1 * delta * GameData.main_time_scale, max_time)
	one_hour_timer_time = min(one_hour_timer_time + 1 * delta * GameData.main_time_scale, max_time)
	#if fmod(current_time, seconds_per_unit_time) < epsilon and current_time != 0 and current_time != max_time:
	#	unit_time_passed.emit()
		
	#print(fmod(current_time, seconds_per_unit_time))
	
	if unit_timer_time >= seconds_per_unit_time:
		unit_timer_time -= seconds_per_unit_time
		unit_time_passed.emit()
		
	if one_hour_timer_time >= seconds_per_one_hour:
		one_hour_timer_time -= seconds_per_one_hour
		one_hour_passed.emit()
		
	if current_time == max_time:
		timeout.emit()
		queue_free()
