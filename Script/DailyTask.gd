extends Node

class_name DailyTask

var computer_task: Array[int] = [] # queue. element 0 for typing, 1 for document task.
var typing_task : int # amount of tasks
var file_sorting_task : int # amount of tasks
var copy_machine_task: int # amount of tasks
var water_clean_task: int # amount of tasks

signal computer_task_changed(new_value: Array[int])
signal copy_machine_task_changed(new_value: int)
signal water_clean_task_changed(new_value: int)

signal max_value(max_computer_task : int, 
max_typing_tast : int, 
max_file_sorting_task : int, 
max_copy_machine_task : int,
max_water_clean_task : int)

func _ready():
	_init()
	
	var current_stage = GameData.stage_level
	task_init(current_stage)
	
	shuffle_computer_task_queue()
	
	
	print("test emit " + str(computer_task.size()))
	call_deferred("emit_max_value")
	

func emit_max_value():
	max_value.emit(computer_task.size(), typing_task, file_sorting_task, copy_machine_task, water_clean_task)

func _init():
	computer_task = []
	copy_machine_task = 0
	water_clean_task = 0
	
	typing_task = 0
	file_sorting_task = 0

func task_init(current_stage: int):
	match current_stage:
		1:
			add_to_computer_task_queue(0)
			add_to_computer_task_queue(1)
			return
		2:
			task_init(1)
			update_copy_machine_task(1)
			return
		3:
			task_init(2)
			add_to_computer_task_queue(0)
			add_to_computer_task_queue(1)
			return
		4:
			task_init(3)
			update_copy_machine_task(1)
			return
		5:
			task_init(4)
			add_to_computer_task_queue(0)
			add_to_computer_task_queue(1)
			return

func shuffle_computer_task_queue():
	computer_task.shuffle()

func add_to_computer_task_queue(task_id: int):
	computer_task.push_back(task_id)
	computer_task_changed.emit(computer_task)
	
	
	#file add number
	if task_id == 0:
		typing_task += 1
	else:
		file_sorting_task += 1
	
func pop_computer_task_queue():
	if computer_task.is_empty():
		return
	
	computer_task.pop_front()
	computer_task_changed.emit(computer_task)
	

func update_copy_machine_task(amount: int):
	copy_machine_task += amount
	var new_value = copy_machine_task
	copy_machine_task_changed.emit(new_value)

func update_water_clean_task(new_value: int):
	water_clean_task = new_value
	water_clean_task_changed.emit(new_value)
