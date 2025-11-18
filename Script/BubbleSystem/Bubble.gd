extends Control


@onready var label = $MarginContainer/Label
@onready var timer = $Timer

const MAX_WIDTH = 500 # If the text gets wider than this (256 pixels)

var text = "" # Stores the entire message we need to display.
var letter_index = 0 # Keeps track of which letter we're currently on when typing.

var letterTime = 0.03 # How fast the text types out (0.03 seconds per letter).
signal finishDisplay() # This signal fires off when the whole message is done typing.


func textToDisPlay(string : String):
	text = string
	label.text = string # Load the whole text first so Godot can figure out how big it needs to be.

	# Wait for the Control node's size to update after setting the text. (A bit unreliable for size checking!)
	await resized 
	
	print(size.x) # Debugging: Check the current width.
	
	# Try to set the bubble's minimum width, either to the calculated size or MAX_WIDTH.
	custom_minimum_size.x = min(MAX_WIDTH, size.x) 
	
	print(custom_minimum_size.x) # Debugging: Check the final minimum width chosen.
	
	if size.x > MAX_WIDTH:
		# If the text is super long (wider than our limit), turn on word wrapping!
		label.autowrap_mode = TextServer.AUTOWRAP_WORD 
		
		# Wait a couple of times to make sure the height recalculates after wrapping. (A common, but clumsy, trick.)
		await resized 
		await resized
		
		# Now that we have the final height, lock the bubble's minimum height.
		custom_minimum_size.y = size.y
		
	# Center the bubble horizontally (This positioning logic is questionable!)
	global_position.x = size.x/2 
	# Position the bubble a little below its own calculated height.
	global_position.y = size.y + 24 
	
	label.text ="" # Clear the label so we can start the typing effect.
	displayLetter() # Start the typing
	
	
func displayLetter():
	# Add the next single letter to the screen.
	label.text += text[letter_index]
	
	letter_index+=1
	
	# Check if we've typed the very last letter.
	if letter_index >= text.length():
		finishDisplay.emit() # we're done
		return
		
	# Start the timer to call this function again for the next letter.
	timer.start(letterTime)


func _on_timer_timeout() -> void:
	# When the timer runs out, type the next letter
	displayLetter()
