#202221035현동우
extends Button

@onready var options_panel = $"../../Options"

#설정창보이기(show option screen)
func _on_pressed():
	SoundManager.play_startclick_sound()
	options_panel.visible = true
