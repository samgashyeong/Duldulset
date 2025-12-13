#202322158 이준상
# This file controls the visual representation and animation of the in-game clock UI.


extends TextureRect


# Resource for the texture containing all clock frames (spritesheet).
@export var clock_atlas: AtlasTexture = null
# Reference to the AnimationPlayer node for controlling animations.
@onready var animation = $"../AnimationPlayer"
# Reference to the Label node displaying the current time ("9:00").
@onready var timeText = $"../../Label"
# Reference to the TimeoutText node, likely used for the time warning animation.
@onready var timeVar = $"../../TimeoutText"
# Constant defining the width of a single clock frame in the atlas.
const FRAME_WIDTH = 32
# Constant defining the height of a single clock frame in the atlas.
const FRAME_HEIGHT = 32
# The starting hour of the game clock.
const START_TIME = 9


# Signal emitted when the clock time changes, carrying the new time as an integer.
signal changeClock(time : int)
func _ready():
	# Ignore mouse input to prevent interference with other UI elements.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Duplicate the atlas texture to safely modify its region.
	texture = clock_atlas.duplicate()
	# Initialize the timeout text scale to zero (hidden).
	timeVar.scale = Vector2(0, 0)
	# Set the initial clock frame to the first frame (index 0).
	setClockFrame(0)
		
	
		
# Updates the clock UI (frame and animation) based on the current game hour.
func changeClockUi(currentClock: int):
	# Calculate the frame index based on the current clock time minus the start time.
	var curFrame = currentClock - 9
	# Update the visual clock frame.
	setClockFrame(curFrame)
	# textAnimation(curFrame) - Note: textAnimation is called inside setClockFrame.
		

# Sets the region of the AtlasTexture to display the specified clock frame.
func setClockFrame(frame_index: int):
	# Emit the signal with the actual time corresponding to the frame index.
	changeClock.emit(START_TIME+frame_index)
	# Check if the texture is indeed an AtlasTexture before manipulating its region.
	if texture is AtlasTexture:
		# Calculate the new region (Rect2) for the specific frame index.
		var new_region = Rect2(
			frame_index * FRAME_WIDTH,	# X position: frame index * frame width
			0,	 	 	 	 	 	 	# Y position: always 0 (assuming a horizontal strip)
			FRAME_WIDTH,	 	 	 	# Width of the frame
			FRAME_HEIGHT	 	 	 	# Height of the frame
		)
		
		# Apply the new region to the AtlasTexture.
		(texture as AtlasTexture).region = new_region
		
		# Start the text update and animation sequence.
		textAnimation(frame_index)

# Handles the animation sequence for displaying the time change.
func textAnimation(frame : int):
	# Format the current time into a display string ("9:00").
	var timeString = str(9+frame)+":00"
	
	# Play the clock sound effect.
	SoundManager.play_clock_sound()
	
	# Start the first part of the clock change animation (scale out).
	animation.play("change_clock")
	# Wait for the first animation to finish before proceeding.
	await animation.animation_finished
	# Update the time text on the Label.
	timeText.text = timeString
	# Wait for one frame to ensure the text update is rendered.
	await get_tree().process_frame
	# Start the second part of the clock change animation (scale in).
	animation.play("change_clock_2")
	
	# Check if the current time is the critical end time (6 PM or 18:00).
	if(frame+9 == 18):
		# Wait for the second animation to finish.
		await animation.animation_finished
		# Play a countdown sound effect.
		SoundManager.play_count_down_sound()
		# Start the final time-up warning animation.
		animation.play("timeWillGone")
