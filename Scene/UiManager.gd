#202322158 이준상
extends CanvasLayer


@onready var dialogueHandlerNode = $"../DialogueHandler"
@onready var health = $VBoxContainer/HP
@onready var stamia = $VBoxContainer/Stamina
@onready var point = $VBoxContainer/Point
@onready var giiyoung = $"../Giiyoung"

var currentTime = 9

var gameTimer
var clockUi

var totalCom = 0
var totalWater = 0
var totalCopy = 0
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
	var daily_task = DailyTask.new()

	daily_task.copy_machine_task = 8
	daily_task.water_clean_task = 7
	$Label.text = "Today Work!
   -Personal work (%d/%d)
   -Copier's work (%d/%d)" % [0, daily_task.copy_machine_task, 0, daily_task.water_clean_task]
	

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
	print("타임아웃")
	
	
func changeCoffeeState(coffee : int):
	$VBoxContainer/HBoxContainer/CoffeeCount.text = str(coffee)
func changeCreamState(cream : int):
	$VBoxContainer/HBoxContainer/CreamCount.text = str(cream)
func changeSugarState(sugar : int):
	$VBoxContainer/HBoxContainer/SugarCount.text = str(sugar)
