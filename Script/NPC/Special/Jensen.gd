# 202322111 임상인
# Define 'Jensen' special character for the special event.
extends Special

func _ready():
	dialogue_path = "res://Dialogue/Special/Jensen/jensen.dtl"
	character_path = "res://Dialogue/Char/Jensen.dch"
	
	# the order is important
	super()
