# 202322111 임상인
# This script is for implementing custom game timer for the main game logic.

extends Node

class_name GameTimer

var current_time: float = 0 # seconds in real time (for entire stage timer).
var unit_timer_time: float = 0 # seconds in real time (for unit time passed timer).
var one_hour_timer_time: float = 0 # seconds in real time (for one hour passed timer).
@export var max_time: float = 270 # seconds in real time. 9 hours in game time.
var seconds_per_unit_time: float = max_time * 1/9 * 1/60 # seconds per minute in game time.
var seconds_per_one_hour: float = max_time * 1/9 # seconds per hour in game time.


signal timeout() # time over
signal unit_time_passed() # one game minute passed
signal one_hour_passed() # one game hour passed


# This function updates each timer and emit signals every frame.
func _process(delta: float) -> void:
	current_time = min(current_time + 1 * delta * GameData.main_time_scale, max_time)
	unit_timer_time = min(unit_timer_time + 1 * delta * GameData.main_time_scale, max_time)
	one_hour_timer_time = min(one_hour_timer_time + 1 * delta * GameData.main_time_scale, max_time)
	
	if unit_timer_time >= seconds_per_unit_time:
		unit_timer_time -= seconds_per_unit_time
		unit_time_passed.emit()
		
	if one_hour_timer_time >= seconds_per_one_hour:
		one_hour_timer_time -= seconds_per_one_hour
		one_hour_passed.emit()
	
	if current_time == max_time:
		timeout.emit()
		queue_free()
