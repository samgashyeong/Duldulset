#202322158 이준상
#This node script Following Player(Giiyoung)
extends TextureRect

@onready var giiyoung = $"../../Giiyoung"

# Tween object used to manage and control the offset animation상
var offset_tween: Tween = null
# A custom offset vector to be animated by the Tween (not used in the provided code snippet, 
# but seems intended to be used for the animation effect)
var anim_offset: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Sets the initial position immediately to Giiyoung's position plus a small offset 
	# to prevent a visual jump on start.
	self.position = giiyoung.position+Vector2(1, 10)


# Called every frame (for constant updates and smooth movement)
func _process(delta: float) -> void:
	#Calculate the final target position: Giiyoung's position + constant visual offset
	var target_position: Vector2 = giiyoung.position + Vector2(-5, -24)
	
	self.position = target_position
