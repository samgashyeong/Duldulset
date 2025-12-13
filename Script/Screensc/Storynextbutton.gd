#202221035현동우
extends Button 

#(make sound when pressed)
func _on_pressed():
	SoundManager.play_specialclick_sound()
