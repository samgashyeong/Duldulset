#202322158 이준상

extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $Timer
@onready var angryTimer =$AngryTimer
#@onready var progressbar = $"../TextureProgressBar"

const MAX_WIDTH = 200

var text_buffer = "" 
var letter_index = 0 
var letterTime = 0.03
signal finishDisplay()
var dialogueResource : Coffee

var currentMethod : Type.StaffMethod

var angryTime = 20.0

var origin_pos : Vector2     
var is_shaking : bool = false  

func _ready():
	label.text = ""

func _process(delta):
	if not angryTimer.is_stopped():
		var time_left = angryTimer.time_left
		var ratio = 1.0 - (time_left / angryTime)
		
		modulate = Color.WHITE.lerp(Color.RED, ratio)
		
		var shake_intensity = ratio * 5.0
		var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		
		label.position = origin_pos + offset

	
		
		
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
			origin_pos = label.position
			angryTimer.start(angryTime)
		elif(currentMethod ==Type.StaffMethod.CHECK):
			print("checking coffee..")
		return
		
	timer.start(letterTime)

func _on_timer_timeout() -> void:
	displayLetter()
	


func _on_angry_timer_timeout() -> void:
	print("timeout")
	var waitTimer = get_tree().create_timer(0.3)
	await waitTimer.timeout
	hide_bubble()

const HIDE_DURATION = 0.3

func hide_bubble():
	var tween = create_tween()
	print("hideBubble")

	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), HIDE_DURATION)
	
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), HIDE_DURATION)
	
	await tween.finished 
	
	queue_free()
