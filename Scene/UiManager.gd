#202322158 이준상
extends CanvasLayer


@onready var dialogueHandlerNode = $"../DialogueHandler"
@onready var health = $VBoxContainer/HP
@onready var stamia = $VBoxContainer/Stamina
@onready var point = $VBoxContainer/Point
@onready var giiyoung = $"../Giiyoung"

@onready var taskList = $"../GameSystem/TaskList"

var currentTime = 9

var gameTimer
var clockUi

var totalCom = 0
var totalType = 0
var totalFile = 0
var totalWater = 0
var totalCopy = 0


var leftCom = 0
var leftType = 0
var leftFile = 0
var leftWater = 0
var leftCopy = 0

var task_text = """Personal task({0}/{1})\n\t- Typing ({2}/{3})\n\t- File ({4}/{5})"""
var withWater = """\nCleaning floor (remain {0})"""
var withCopy = """\nCopymechine ({0}/{1})"""
func _ready() -> void:
	clockUi = get_node("ClockSystem/HBoxContainer/TextureRect")
	gameTimer = get_node("../GameSystem/GameTimer")
	
	clockUi.changeClockUi(currentTime)
	dialogueHandlerNode.effectHealth.connect(calculateHealth)
	dialogueHandlerNode.effectStamia.connect(calculateStamia)
	dialogueHandlerNode.effectPoint.connect(calculatePoint)
	
	giiyoung.point_changed.connect(aniamtionPoint)
	giiyoung.health_changed.connect(animationHealth)
	giiyoung.stamina_changed.connect(animationStamia)
	
	gameTimer.timeout.connect(_timeout)
	gameTimer.one_hour_passed.connect(changeClockUi)
	
	GameData.add_coffee.connect(changeCoffeeState)
	GameData.add_cream.connect(changeCreamState)
	GameData.add_sugar.connect(changeSugarState)
	
	
	if taskList.has_signal("max_value"):
		print("has signal!!!!")
	
	taskList.max_value.connect(setMaxValue)
	taskList.computer_task_changed.connect(computerTaskChanged)
	taskList.water_clean_task_changed.connect(waterCleanTaskChanged)
	taskList.copy_machine_task_changed.connect(copyMachineTaskChanged)
	
	

func computerTaskChanged(num : Array[int]):
	
	var comTyping = 0
	var comFile = 0
	
	for i in num:
		if(i == 0):
			comTyping+=1
		else:
			comFile+=1
	
	leftType = comTyping
	leftFile = comFile
	leftCom = num.size()
	
	
	changeTaskText()

func waterCleanTaskChanged(num : int):
	leftWater = num
	print("leftWater" + str(num))
	changeTaskText()
	
func copyMachineTaskChanged(num : int):
	leftCopy = num
	changeTaskText()
	


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

	
	totalCom = max_computer_task
	totalType = max_typing_task
	totalFile = max_file_sorting_task
	totalCopy = max_copy_machine_task
	totalWater = max_water_clean_task
	
	leftCom = totalCom
	leftType = totalType
	leftFile = totalFile
	leftWater = totalWater
	leftCopy = totalCopy
	
	var finaltaskText = task_text.format([
		0, # {0}
		totalCom,     # {1}
		0,                           # {2}
		totalType,             # {3}
		0,                           # {4}
		totalFile,       # {5}      # {6}          
	])
	
	var withText = ""
	if totalCopy > 0 :
		withText = withCopy.format([
			0, totalCopy
		])
	
	finaltaskText+=withText
	
	$Label.text = finaltaskText
	
	

func changeTaskText():
	var finaltaskText = task_text.format([
		totalCom-leftCom, # {0}
		totalCom,     # {1}
		totalType-leftType,                           # {2}
		totalType,             # {3}
		totalFile-leftFile,                           # {4}
		totalFile,       # {5}      # {6}          
	])
	
	if(totalCopy > 0):
		var copy = withCopy.format([
			leftCopy,
			totalCom
		])
		finaltaskText += copy
	if(leftWater > 0):
		var waterText = withWater.format([
			leftWater
		])
		finaltaskText += waterText
	
	$Label.text = finaltaskText


func calculateHealth(_health : int):
	var finalPoint = health.value + _health
	animationHealth(finalPoint, _health)

func calculateStamia(_stamia : float):
	var finalPoint = stamia.value + _stamia
	animationStamia(finalPoint, _stamia)

func calculatePoint(_point : int):
	var onlyPoint = point.text.split()[0]
	var finalPoint = int(onlyPoint) + _point
	aniamtionPoint(finalPoint, _point) 
	
func animationHealth(finalPoint : int, value : int):
	var tween = create_tween()
	if(value < 0):
		SoundManager.play_DamageCh_sound()
	tween.tween_property(
		health, 
		"value", 
		finalPoint,
		0.5 
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func animationStamia(finalPoint : float, value : float):
	var tween = create_tween()
	
	tween.tween_property(
		stamia, 
		"value", 
		finalPoint, 
		0.5 
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
func aniamtionPoint(_point : int, value : int):
	point.text = str(_point) + " Point"
	SoundManager.play_PointUpCh_sound()

func changeClockUi():
	currentTime += 1
	clockUi.changeClockUi(currentTime)
	
func _timeout():
	print("timeout")
	
	
func changeCoffeeState(coffee : int):
	$VBoxContainer/HBoxContainer/CoffeeCount.text = str(coffee)
func changeCreamState(cream : int):
	$VBoxContainer/HBoxContainer/CreamCount.text = str(cream)
func changeSugarState(sugar : int):
	$VBoxContainer/HBoxContainer/SugarCount.text = str(sugar)
