#202322158 이준상
extends TextureRect


@export var clock_atlas: AtlasTexture = null
@onready var animation = $"../AnimationPlayer"
@onready var timeText = $"../../Label"
@onready var timeVar = $"../../TimeoutText" 
const FRAME_WIDTH = 32
const FRAME_HEIGHT = 32
const START_TIME = 9


signal changeClock(time : int)
func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture = clock_atlas.duplicate()
	timeVar.scale = Vector2(0, 0)
	setClockFrame(0)
		
	
		

func changeClockUi(currentClock: int):
	var curFrame = currentClock - 9
	setClockFrame(curFrame)
	#textAnimation(curFrame)
		

func setClockFrame(frame_index: int):
	changeClock.emit(START_TIME+frame_index)
	if texture is AtlasTexture:
		var new_region = Rect2(
			frame_index * FRAME_WIDTH, 
			0,                         
			FRAME_WIDTH,               
			FRAME_HEIGHT               
		)
		
		(texture as AtlasTexture).region = new_region
		
		textAnimation(frame_index)

func textAnimation(frame : int):
	var timeString = str(9+frame)+":00"
	
	animation.play("change_clock")
	await animation.animation_finished
	timeText.text = timeString
	await get_tree().process_frame
	animation.play("change_clock_2")
	
	
	if(frame+9 == 18):
		await animation.animation_finished
		SoundManager.play_count_down_sound()
		animation.play("timeWillGone")
	
	
	
	
