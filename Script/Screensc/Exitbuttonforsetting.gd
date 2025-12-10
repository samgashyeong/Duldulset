extends Button

@onready var options = get_parent()

func _on_pressed():
	SoundManager.play_specialclick_sound()
	options.visible = false
