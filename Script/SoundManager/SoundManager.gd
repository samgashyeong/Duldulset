extends Node

func play_startclick_sound():
	$StartButton.play()

func play_quit_sound_and_exit():
	$QuitButton.play()
	await $QuitButton.finished
	get_tree().quit()
