extends Node

class_name GameTimer

var current_time: float = 0 # seconds in real time.
@export var max_time: float = 3 # seconds in real time. 9 hours in game time.
var seconds_per_unit_time: float = max_time * 1/9 * 1/60 # seconds per minutes in game time.

var epsilon = 0.001

signal timeout() # time over
signal unit_time_passed() # one game minute passed

func _process(delta: float) -> void:
	current_time = min(current_time + 1 * delta * GameData.main_time_scale, max_time)

	if fmod(current_time, seconds_per_unit_time) < epsilon and current_time != 0 and current_time != max_time:
		unit_time_passed.emit()
		
	print(fmod(current_time, seconds_per_unit_time))
	
	if current_time == max_time:
		timeout.emit()
		queue_free()
