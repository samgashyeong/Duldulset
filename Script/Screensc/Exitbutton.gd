#202221035 현동우
extends Button 

#사운드플레이후종료(play sound and exit)
func _on_pressed():
	SoundManager.play_quit_sound_and_exit()
