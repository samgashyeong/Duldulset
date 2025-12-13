# Student ID and Name (for context, not code functionality)
#202322158 이준상
extends Node

# Timer for managing attendance choice timeout
var attendance_timer: Timer
# Timer for managing the intro sequence timeout
var intro_timer: Timer
# Default timeout for a student's choice during attendance (1.5 seconds)
var current_choice_timeout: float = 1.5
# Default timeout for the introduction phase (3.0 seconds)
var intro_timeout: float = 3.0
# Flag to check if the script is currently waiting for a user choice/input
var is_waiting_for_choice: bool = false

# Array defining the order of students for attendance
var attendance_order = ["junsang", "dongwoo", "yeonghee", "minseo", "giyeong"]
# Index tracking the current student in the attendance_order array
var current_student_index = 0

# Reference to the Dialogic handler node (assumes it's the current node itself or a child)
@onready var dialoghandler = $"."

# Called when the node enters the scene tree for the first time
func _ready():
	# Connects the global Dialogic signal 'signal_event' to the custom handler function
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	# Initialize and configure the attendance timer
	attendance_timer = Timer.new()
	attendance_timer.wait_time = current_choice_timeout
	attendance_timer.one_shot = true
	# Connects the timeout signal to the timeout handler function
	attendance_timer.timeout.connect(_on_attendance_timer_timeout)
	add_child(attendance_timer)
	
	# Initialize and configure the intro timer
	intro_timer = Timer.new()
	intro_timer.wait_time = intro_timeout
	intro_timer.one_shot = true
	# Connects the timeout signal to the intro timeout handler function
	intro_timer.timeout.connect(_on_intro_timer_timeout)
	add_child(intro_timer)

# Signal emitted to apply a health effect
signal effectHealth(health : int)
# Signal emitted to apply a stamina effect
signal effectStamia(stamia : int)
# Signal emitted to apply a point/score effect
signal effectPoint(point : int)

# Enumeration for special character names used in event handling
enum SpeicalName{
	Teemu,
	Sinyoung,
	Jenson
}

# Handler function for signals received from Dialogic
func _on_dialogic_signal(argument: Variant):
	print("Received signal with argument: ", argument)
	
	# Check if the signal argument is a Dictionary (likely for character events with effects)
	if argument is Dictionary:
		var name = argument.get("Name")
		#print(name)
		var effect = argument.get("Effect")
		# Calls the corresponding event handler function based on the character name
		match name:
			"Teemu":
				teemuEvent(effect)
			"Sinyoung":
				sinyoungEvent(effect)
			"Jenson":
				JensonEvent(effect)
	# Check if the signal argument is a String (likely for timer/flow control commands)
	elif argument is String:
		# attendance check signal manager
		# Handles various string commands for managing timers and attendance flow
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


# Starts the attendance timer, indicating the script is waiting for user input
func start_attendance_timer():
	is_waiting_for_choice = true
	attendance_timer.start()

# Called when the attendance timer runs out
func _on_attendance_timer_timeout():
	print("timeout")
	# If still waiting for a choice, proceed to the next student (implying no choice was made)
	if is_waiting_for_choice:
		is_waiting_for_choice = false
		proceed_to_next_student()

# Advances the attendance check to the next student in the list
func proceed_to_next_student():
	current_student_index += 1
	
	# Checks if there are more students in the list
	if current_student_index < attendance_order.size():
		var next_student = attendance_order[current_student_index]
		# Jumps the Dialogic timeline to the label corresponding to the next student's name
		Dialogic.Jump.jump_to_label(next_student)
		# Forces the next event in the timeline to handle the jump
		Dialogic.handle_next_event()
	# If all students have been processed
	else:
		print("end")
		if Dialogic.Jump:
			# Jumps the Dialogic timeline to the "end" label
			Dialogic.Jump.jump_to_label("end")
			Dialogic.handle_next_event()

# Stops the attendance timer and ends the Dialogic timeline upon completion
func attendance_finished():
	is_waiting_for_choice = false
	attendance_timer.stop()
	Dialogic.end_timeline()

# Starts the intro timer
func start_intro_timer():
	print("Intro Timer Started")
	intro_timer.start()

# Called when the intro timer runs out
func _on_intro_timer_timeout():
	# If a timeline is currently running
	if Dialogic.current_timeline:
		# Jumps the Dialogic timeline to the first student ("junsang")
		Dialogic.Jump.jump_to_label("junsang")
		Dialogic.handle_next_event()
	# Resets the student index to the beginning (although it should be 0 already after intro)
	current_student_index = 0

# Stops the intro timer
func stop_intro_timer():
	is_waiting_for_choice = false
	intro_timer.stop()

# Stops the main attendance timer
func stop_timer():
	is_waiting_for_choice = false
	attendance_timer.stop()
				
# Handles events specific to the character "Teemu"
func teemuEvent(effect : int):
	match effect:
		1:
			effectElement(10, 0, 0)
		2:
			effectElement(10, 0, 0)
		3:
			effectElement(10, 0, 0)
		4:
			effectElement(50, 0, 200)

# Handles events specific to the character "Sinyoung"
func sinyoungEvent(effect : int):
	match effect:
		1:
			effectElement(-20, 0, -100)
		2:
			effectElement(20, 0, 100)
			
# Handles events specific to the character "Jenson"
func JensonEvent(effect : int):
	match effect:
		1:
			effectElement(-10, 0, -100)
		2:
			effectElement(-50, 0, -200)
			
# Helper function to emit signals for health, stamina, and point changes
func effectElement(
	health : int,
	stamia : int,
	point : int
):
	# Prints the values for debugging
	print(str(health) + str(stamia) + str(point))
	# Emits signals with the corresponding effect values
	effectHealth.emit(health)
	effectStamia.emit(stamia)
	effectPoint.emit(point)
