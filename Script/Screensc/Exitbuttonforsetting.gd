#202221035 현동우
extends Button

@onready var options = get_parent()

#설정창종료(exit from options screen)
func _on_pressed():
	SoundManager.play_specialclick_sound()
	options.visible = false
