#202322158 이준상
# Manages the user interface, including player stats, tasks, and the clock.
extends CanvasLayer

# Node references, ready when the scene starts.
@onready var dialogueHandlerNode = $"../DialogueHandler"
@onready var health = $VBoxContainer/HP
@onready var stamia = $VBoxContainer/Stamina
@onready var point = $VBoxContainer/Point
@onready var giiyoung = $"../Giiyoung" # Player node

@onready var taskList = $"../GameSystem/TaskList"

# Game time state
var currentTime = 9

# UI and timer variables
var gameTimer
var clockUi

# Variables to track total tasks
var totalCom = 0
var totalType = 0
var totalFile = 0
var totalWater = 0
var totalCopy = 0

# Variables to track remaining tasks
var leftCom = 0
var leftType = 0
var leftFile = 0
var leftWater = 0
var leftCopy = 0

# Text templates for the task list UI
var task_text = """Personal task({0}/{1})\n\t- Typing ({2}/{3})\n\t- File ({4}/{5})"""
var withWater = """\nCleaning floor (remain {0})"""
var withCopy = """\nCopymachine ({0}/{1})"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get nodes for clock and game timer
	clockUi = get_node("ClockSystem/HBoxContainer/TextureRect")
	gameTimer = get_node("../GameSystem/GameTimer")
	
	# Set stamina bar max_value to match player's max_stamina
	stamia.max_value = giiyoung.max_stamina
	print("Stamina bar max_value set to: ", stamia.max_value)
	
	# Initialize clock UI
	clockUi.changeClockUi(currentTime)
	
	# Connect signals from DialogueHandler to update player stats
	dialogueHandlerNode.effectHealth.connect(calculateHealth)
	dialogueHandlerNode.effectStamia.connect(calculateStamia)
	dialogueHandlerNode.effectPoint.connect(calculatePoint)
	
	# Connect signals from the player to update UI animations/feedback
	giiyoung.point_changed.connect(aniamtionPoint)
	giiyoung.health_changed.connect(animationHealth)
	giiyoung.stamina_changed.connect(animationStamia)
	
	# Connect signals from the game timer
	gameTimer.timeout.connect(_timeout)
	gameTimer.one_hour_passed.connect(changeClockUi)
	
	# Connect signals for coffee-related item changes
	GameData.add_coffee.connect(changeCoffeeState)
	GameData.add_cream.connect(changeCreamState)
	GameData.add_sugar.connect(changeSugarState)
	
	# Check if the taskList has the 'max_value' signal
	if taskList.has_signal("max_value"):
		print("has signal!!!!")
	
	# Connect signals from the TaskList to update task progress
	taskList.max_value.connect(setMaxValue)
	taskList.computer_task_changed.connect(computerTaskChanged)
	taskList.water_clean_task_changed.connect(waterCleanTaskChanged)
	taskList.copy_machine_task_changed.connect(copyMachineTaskChanged)
	
	
# Called when a computer-related task (typing or file sorting) is completed.
func computerTaskChanged(num : Array[int]):
	
	var comTyping = 0
	var comFile = 0
	
	# Count the number of each type of computer task remaining
	for i in num:
		if(i == 0):
			comTyping+=1
		else:
			comFile+=1
	
	# Update remaining task counts
	leftType = comTyping
	leftFile = comFile
	leftCom = num.size()
	
	# Refresh the task list display
	changeTaskText()

# Called when a water cleaning task is completed.
func waterCleanTaskChanged(num : int):
	leftWater = num
	print("leftWater" + str(num))
	changeTaskText()

# Called when a copy machine task is completed.
func copyMachineTaskChanged(num : int):
	leftCopy = num
	changeTaskText()
	

# Sets the initial maximum values for all tasks at the start of the game.
func setMaxValue(max_computer_task : int, 
max_typing_task : int, 
max_file_sorting_task : int, 
max_copy_machine_task : int,
max_water_clean_task : int):
	print("setMaxValue called!")
	print("max_computer_task: ", max_computer_task)
	print("max_copy_machine_task: ", max_copy_machine_task)
	print("max_water_clean_task: ", max_water_clean_task)
	print("test " + str(max_computer_task))	
	var total_personal_work_max = max_typing_task + max_file_sorting_task
	var total_personal_work_current = 0

	# Store total task counts
	totalCom = max_computer_task
	totalType = max_typing_task
	totalFile = max_file_sorting_task
	totalCopy = max_copy_machine_task
	totalWater = max_water_clean_task
	
	# Initialize remaining task counts to totals
	leftCom = totalCom
	leftType = totalType
	leftFile = totalFile
	leftWater = totalWater
	leftCopy = totalCopy
	
	# Format the initial task text
	var finaltaskText = task_text.format([
		0, # {0} Completed personal tasks
		totalCom,     # {1} Total personal tasks
		0,                           # {2} Completed typing
		totalType,             # {3} Total typing
		0,                           # {4} Completed file sorting
		totalFile,       # {5} Total file sorting
	])
	
	# Add copy machine task text if applicable
	var withText = ""
	if totalCopy > 0 :
		withText = withCopy.format([
			0, totalCopy
		])
	
	finaltaskText+=withText
	
	# Set the label text
	$Label.text = finaltaskText
	
	
# Updates the task list UI text based on current progress.
func changeTaskText():
	# Format the main task text with current progress
	var finaltaskText = task_text.format([
		totalCom-leftCom, # {0} Completed personal tasks
		totalCom,     # {1} Total personal tasks
		totalType-leftType,                           # {2} Completed typing
		totalType,             # {3} Total typing
		totalFile-leftFile,                           # {4} Completed file sorting
		totalFile,       # {5} Total file sorting
	])
	
	# Add copy task text if there are copy tasks
	if(totalCopy > 0):
		var copy = withCopy.format([
			totalCopy-leftCopy,
			totalCopy
		])
		finaltaskText += copy
	# Add water cleaning task text if there are water tasks
	if(leftWater > 0):
		var waterText = withWater.format([
			leftWater
		])
		finaltaskText += waterText
	
	# Update the UI label
	$Label.text = finaltaskText

# Calculates the final health value after a change.
func calculateHealth(_health : int):
	var finalPoint = health.value + _health
	animationHealth(finalPoint, _health)

# Calculates the final stamina value after a change.
func calculateStamia(_stamia : float):
	var finalPoint = stamia.value + _stamia
	animationStamia(finalPoint, _stamia)

# Calculates the final point value after a change.
func calculatePoint(_point : int):
	var onlyPoint = point.text.split()[0]
	var finalPoint = int(onlyPoint) + _point
	aniamtionPoint(finalPoint, _point) 
	
# Updates the health bar and plays a sound on damage.
func animationHealth(finalPoint : int, value : int):
	if(value < 0):
		SoundManager.play_DamageCh_sound()
	
	health.value = finalPoint

# Updates the stamina bar.
func animationStamia(finalPoint : float, value : float):
	# Debug prints to check values
	#print("Stamina Debug - finalPoint: ", finalPoint, " value: ", value)
	
	stamia.value = finalPoint

# Updates the point display text and plays a sound.
func aniamtionPoint(_point : int, value : int):
	point.text = str(_point) + " Point"
	SoundManager.play_PointUpCh_sound()

# Advances the clock UI by one hour.
func changeClockUi():
	currentTime += 1
	clockUi.changeClockUi(currentTime)

# Called when the main game timer runs out.
func _timeout():
	print("timeout")
	
# Updates the coffee count UI.
func changeCoffeeState(coffee : int):
	$VBoxContainer/HBoxContainer/CoffeeCount.text = str(coffee)
# Updates the cream count UI.
func changeCreamState(cream : int):
	$VBoxContainer/HBoxContainer/CreamCount.text = str(cream)
# Updates the sugar count UI.
func changeSugarState(sugar : int):
	$VBoxContainer/HBoxContainer/SugarCount.text = str(sugar)
