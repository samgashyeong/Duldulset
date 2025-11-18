extends Control

@onready var label = $MarginContainer/Label
@onready var timer = $Timer
@onready var angryTimer = $AngryTimer

const MAX_WIDTH = 500 

var text_buffer = "" 
var letter_index = 0 
var letterTime = 0.03
signal finishDisplay()
var dialogueResource : Coffee

var currentMethod : Type.StaffMethod

var angryTime = 5.0
func _ready():
	
	label.text = ""

func textToDisPlay(type : Type.StaffMethod, coffee : int = 0, cream : int = 0, sugar : int = 0):
	var string
	currentMethod = type
	match type:
		Type.StaffMethod.ORDER:
			string = "!!"
		Type.StaffMethod.START0:
			string = dialogueResource.orders[0].dialog
		Type.StaffMethod.START1:
			string = dialogueResource.orders[1].dialog
		Type.StaffMethod.START2:
			string = dialogueResource.orders[2].dialog
		Type.StaffMethod.CHECK:
			string = "Drinking..."
	
	timer.stop()
	text_buffer = string
	letter_index = 0
	
	label.text = string 
	
	await get_tree().process_frame 
	
	custom_minimum_size.x = min(MAX_WIDTH, size.x)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().process_frame 
		custom_minimum_size.y = size.y
	
	label.text = "" 
	
	displayLetter()
	

func setDialogueSource(resource):
	dialogueResource = resource
	
func displayLetter():
	if text_buffer.length() == 0:
		return

	label.text += text_buffer[letter_index]
	letter_index += 1
	
	if letter_index >= text_buffer.length():
		finishDisplay.emit()
		if(currentMethod == Type.StaffMethod.START0 or 
		currentMethod == Type.StaffMethod.START1 or 
		currentMethod == Type.StaffMethod.START2) : 
			angryTimer.start(angryTime)
		elif(currentMethod ==Type.StaffMethod.CHECK):
			print("checking coffee..")
		return
		
	timer.start(letterTime)

func _on_timer_timeout() -> void:
	displayLetter()


func _on_angry_timer_timeout() -> void:
	print("timeout")
