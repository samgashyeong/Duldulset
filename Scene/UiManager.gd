extends CanvasLayer


@onready var dialogueHandlerNode = $"../DialogueHandler"
@onready var health = $VBoxContainer/HP
@onready var stamia = $VBoxContainer/Stamina
@onready var point = $VBoxContainer/Point
@onready var giiyoung = $"../Giiyoung"

var currentTime = 9

var gameTimer
var clockUi
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
	

func calculateHealth(_health : int):
	var finalPoint = health.value + _health
	animationHealth(finalPoint)

func calculateStamia(_stamia : int):
	var finalPoint = stamia.value + _stamia
	animationStamia(finalPoint)

func calculatePoint(_point : int):
	var onlyPoint = point.text.split()[0]
	var finalPoint = int(onlyPoint) + _point
	aniamtionPoint(finalPoint) 
	
func animationHealth(finalPoint : int):
	var tween = create_tween()
	
	tween.tween_property(
		health, 
		"value", 
		finalPoint,
		0.5 
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func animationStamia(finalPoint : int):
	var tween = create_tween()
	
	tween.tween_property(
		stamia, 
		"value", 
		finalPoint, 
		0.5 
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
func aniamtionPoint(_point : int):
	point.text = str(_point) + " Point"

func changeClockUi():
	currentTime += 1
	clockUi.changeClockUi(currentTime)
	
func _timeout():
	print("타임아웃")
