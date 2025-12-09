extends Button

@onready var options_panel = $"../../Options"

func _on_pressed():
	SoundManager.play_startclick_sound()
	options_panel.visible = true
