#202322158 이준상
# This file manages the NPC speech bubble UI, handling text display, timing, and visual feedback (shaking/color change) for orders.


extends MarginContainer

# Reference to the main Label inside the MarginContainer.
@onready var label = $MarginContainer/Label


# Timer for controlling the speed of letter display (typing effect).
@onready var timer = $Timer
# Timer for tracking the time until the staff member becomes angry about a wait.
@onready var angryTimer =$AngryTimer
# Timer for tracking the time until the staff member becomes angry about no order being taken.
@onready var orderTimer = $OrderTimer


# Maximum width the bubble should expand to before wrapping text.
const MAX_WIDTH = 200

# Buffer that holds the full text to be displayed.
var text_buffer = ""
# Index of the current letter being displayed in the typing effect.
var letter_index = 0
# Time delay between displaying each letter.
var letterTime = 0.03
# Signal emitted when the text display (typing effect) is complete.
signal finishDisplay()
# Resource object containing the staff's dialogue and order details.
var dialogueResource : Coffee

# The current method/state the staff member is in (e.g., ORDER, START0, CHECK).
var currentMethod : Type.StaffMethod

# Time limit (in seconds) before the staff member gets angry.
var angryTime = 120.0
# Time limit (in seconds) before the staff member gets angry about no initial order being taken.
var orderTime = 80

# The original position of the label, used as a baseline for shaking effects.
var origin_pos : Vector2
# Flag indicating if the bubble is currently shaking (currently handled by timer check).
var is_shaking : bool = false
# The node (NPC) the bubble is following/targeting.
var target_node : Node2D
# Offset position of the bubble relative to the target node.
var offset : Vector2 = Vector2(50, -100)

# Enum value of the staff member associated with this bubble.
var currentStaff : Type.StaffName

# Signal emitted to add a log entry to the log system.
signal addLog(type : Type.LOG, staffName : Type.StaffName)

func _ready():
	# Initialize the label text to empty.
	label.text = ""

# Sets the NPC node that this bubble will follow.
func set_target(target: Node2D):
	target_node = target

# Executes every frame. Handles bubble following and visual feedback based on timers.
func _process(delta):
	# If a target node is set, update the bubble's global position.
	if target_node != null:
		global_position = target_node.global_position + offset
	
	# Handle angry state visual feedback.
	if not angryTimer.is_stopped():
		var time_left = angryTimer.time_left
		# Calculate ratio of time passed relative to the total angry time.
		var ratio = 1.0 - (time_left / angryTime)
		
		# Interpolate the color from WHITE to RED based on the time ratio.
		modulate = Color.WHITE.lerp(Color.RED, ratio)
		
		# Calculate shake intensity based on time ratio.
		var shake_intensity = ratio * 5.0
		# Apply a random offset to the label position for the shaking effect.
		var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		
		label.position = origin_pos + offset
		
	# Handle order wait state visual feedback.
	if not orderTimer.is_stopped():
		var time_left = orderTimer.time_left
		# Calculate ratio of time passed relative to the total order time.
		var ratio = 1.0 - (time_left / orderTime)
		
		# Interpolate the color from WHITE to YELLOW based on the time ratio.
		modulate = Color.WHITE.lerp(Color.YELLOW, ratio)
		
		# Calculate shake intensity based on time ratio.
		var shake_intensity = ratio * 5.0
		# Apply a random offset to the label position for the shaking effect.
		var offset2 = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		
		label.position = origin_pos + offset2
	
		
		
# Prepares and starts the typing effect for a given dialogue string based on staff method.
func textToDisPlay(type : Type.StaffMethod, coffee : int = 0, cream : int = 0, sugar : int = 0):
	var string
	currentMethod = type
	# Determine the string content based on the staff method.
	match type:
		Type.StaffMethod.ORDER:
			string = "!!" # Initial call for attention/order request
		Type.StaffMethod.START0:
			orderTimer.stop()
			modulate = Color.WHITE
			string = dialogueResource.orders[0].dialog
		Type.StaffMethod.START1:
			orderTimer.stop()
			modulate = Color.WHITE
			string = dialogueResource.orders[1].dialog
		Type.StaffMethod.START2:
			orderTimer.stop()
			modulate = Color.WHITE
			string = dialogueResource.orders[2].dialog
		Type.StaffMethod.CHECK:
			string = "Drinking..." # Dialogue when checking the coffee
	
	
	text_buffer = string
	letter_index = 0
	
	# Reset label properties before size calculation.
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	custom_minimum_size = Vector2.ZERO
	
	# Set the full text temporarily to calculate the required size.
	label.text = string
	# Wait multiple frames to ensure layout is updated for size calculation.
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Calculate the required width, clamped by MAX_WIDTH.
	custom_minimum_size.x = min(MAX_WIDTH, size.x)
	
	# If the text exceeds MAX_WIDTH, enable word wrap and recalculate height.
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().process_frame
		await get_tree().process_frame
		custom_minimum_size.y = size.y
	
	# Clear the label text to begin the typing effect.
	label.text = ""

	# Start the letter display process.
	displayLetter()
	
	
	# If it's the initial order request, start the order timer and save the origin position.
	if(currentMethod == Type.StaffMethod.ORDER):
		origin_pos = label.position
		orderTimer.start(orderTime)
	
	# If it's the CHECK state, stop timers, reset color, and hide the bubble after a delay.
	if(currentMethod == Type.StaffMethod.CHECK):
		angryTimer.stop()
		modulate = Color.WHITE
		await get_tree().create_timer(1).timeout
		hide_bubble()
	

# Sets the resource object containing the dialogue data.
func setDialogueSource(resource):
	dialogueResource = resource
	
# Displays the next letter in the typing sequence.
func displayLetter():
	# Stop if the text buffer is empty.
	if text_buffer.length() == 0:
		return

	# Add the next letter to the label text.
	label.text += text_buffer[letter_index]
	letter_index += 1
	
	# Check if all letters have been displayed.
	if letter_index >= text_buffer.length():
		# Emit signal that display is finished.
		finishDisplay.emit()
		# If the staff has made a specific coffee order, start the angry timer.
		if(currentMethod == Type.StaffMethod.START0 or
		currentMethod == Type.StaffMethod.START1 or
		currentMethod == Type.StaffMethod.START2) :
			origin_pos = label.position
			angryTimer.start(angryTime)
		elif(currentMethod ==Type.StaffMethod.CHECK):
			print("checking coffee..")
		return
		
	# Start the timer for the next letter delay.
	timer.start(letterTime)

# Timer for the typing effect times out (likely unused, as timer is used for letter delay).
# Note: This function seems incorrectly implemented to handle log and re-call displayLetter.
func _on_timer_timeout() -> void:
	# This function may be misplaced or incorrectly wired, usually _on_timer_timeout calls displayLetter.
	# If used as the typing timer, it should be connected to the timer signal.
	# The log emit here is likely an error or a temporary setup.
	addLog.emit(Type.LOG.STAFF_ANGRY_NOT_MAKE_COFFEE)
	displayLetter()
	


# The angry timer times out, meaning the staff member has been waiting too long.
func _on_angry_timer_timeout() -> void:
	print("timeout")
	# Create a brief delay before hiding the bubble.
	var waitTimer = get_tree().create_timer(0.3)
	await waitTimer.timeout
	# Hide and queue free the bubble.
	hide_bubble()

# Constant for the duration of the hide animation.
const HIDE_DURATION = 0.3

# Animates the bubble to hide and then deletes the node.
func hide_bubble():
	var tween = create_tween()
	print("hideBubble")

	# Tween the modulate property to zero alpha (fade out).
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), HIDE_DURATION)
	
	# Tween the scale property (shrink animation).
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), HIDE_DURATION)
	
	# Wait for the tweening to finish.
	await tween.finished
	
	# Delete the node from the scene tree.
	queue_free()


# The order timer times out, meaning the player took too long to take the initial order.
func _on_order_timer_timeout() -> void:
	# Emit a log entry for staff being angry about no order.
	addLog.emit(Type.LOG.STAFF_ANGRY_NOT_ORDER, Type.StaffName.JUNSANG)
	# Hide and delete the bubble.
	hide_bubble()
