extends Node

class_name DailyTask

var computer_task: Array[int] # queue. element 0 for typing, 1 for document task.
var copy_machine_task: int # amount of tasks
var water_clean_task: int # amount of tasks

func _ready():
	_init()
	
	
	

func _init():
	computer_task = []
	copy_machine_task = 0
	water_clean_task = 0
