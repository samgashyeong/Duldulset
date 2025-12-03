#202322158 이준상

extends Node

var attendance_timer: Timer
var intro_timer: Timer
var current_choice_timeout: float = 1.5  # 5 second attendance timer
var intro_timeout: float = 3.0  # 3 second intro timer
var is_waiting_for_choice: bool = false

# order manager
var attendance_order = ["junsang", "dongwoo", "yeonghee", "minseo", "giyeong"]
var current_student_index = 0

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	attendance_timer = Timer.new()
	attendance_timer.wait_time = current_choice_timeout
	attendance_timer.one_shot = true
	attendance_timer.timeout.connect(_on_attendance_timer_timeout)
	add_child(attendance_timer)
	
	#inter timer setting
	intro_timer = Timer.new()
	intro_timer.wait_time = intro_timeout
	intro_timer.one_shot = true
	intro_timer.timeout.connect(_on_intro_timer_timeout)
	add_child(intro_timer)

signal effectHealth(health : int)
signal effectStamia(stamia : int)
signal effectPoint(point : int)

enum SpeicalName{
	Teemu,
	Sinyoung,
	Jenson
}

func _on_dialogic_signal(argument: Variant):
	print("Received signal with argument: ", argument)
	
	if argument is Dictionary:
		var name = argument.get("Name")
		#print(name)
		var effect = argument.get("Effect")
		match name:
			"Teemu":
				teemuEvent(effect)
			"Sinyoung":
				sinyoungEvent(effect)
			"Jenson":
				JensonEvent(effect)
	elif argument is String:
		#attendance check signal manager
		if argument == "start_intro_timer":
			start_intro_timer()
		elif argument == "start_attendance_timer":
			start_attendance_timer()
		elif argument == "attendance_finished":
			attendance_finished()
		elif argument == "stop_intro_timer":
			stop_intro_timer()
		elif argument == "stop_timer":
			stop_timer()


#attendence
func start_attendance_timer():
	is_waiting_for_choice = true
	attendance_timer.start()

func _on_attendance_timer_timeout():
	print("timeout")
	if is_waiting_for_choice:
		is_waiting_for_choice = false
		proceed_to_next_student()

func proceed_to_next_student():
	current_student_index += 1
	
	if current_student_index < attendance_order.size():
		var next_student = attendance_order[current_student_index]
		Dialogic.Jump.jump_to_label(next_student)
		Dialogic.handle_next_event()
	else:
		print("end")
		if Dialogic.Jump:
			Dialogic.Jump.jump_to_label("end")
			Dialogic.handle_next_event()

func attendance_finished():
	is_waiting_for_choice = false
	attendance_timer.stop()
	Dialogic.end_timeline()

func start_intro_timer():
	print("인트로 타이머 시작")
	intro_timer.start()

				
func _on_intro_timer_timeout():
	if Dialogic.current_timeline:
		Dialogic.Jump.jump_to_label("junsang")
		Dialogic.handle_next_event()
	current_student_index = 0

func stop_intro_timer():
	is_waiting_for_choice = false
	intro_timer.stop()

func stop_timer():
	is_waiting_for_choice = false
	attendance_timer.stop()
				
func teemuEvent(effect : int):
	match effect:
		1:
			effectElement(5, 5, 5)
		2:
			effectElement(1, 1, 1)
		3:
			effectElement(1, 1, 1)
		4:
			effectElement(20, 20, 20)

func sinyoungEvent(effect : int):
	match effect:
		1:
			effectElement(-20, -20, 0)
		2:
			effectElement(20, 20, 100)
			

func JensonEvent(effect : int):
	match effect:
		1:
			effectElement(-10, -10, 0)
		2:
			effectElement(-50, -50, 0)
			
func effectElement(
	health : int,
	stamia : int,
	point : int
):
	print(str(health) + str(stamia) + str(point))
	effectHealth.emit(health)
	effectStamia.emit(stamia)
	effectPoint.emit(point)
