extends Node

#처음부터 bgm들리게
func _ready():
	if has_node("BGMPlayer"):
		$BGMPlayer.play()
		
func play_startclick_sound():
	$StartButton.play()

func play_quit_sound_and_exit():
	$QuitButton.play()
	await $QuitButton.finished
	get_tree().quit()
	
func play_specialclick_sound():
	$SpecialButton.play()
	
func play_Storynext_sound():
	$StorynextButton.play()

func play_WalkCh_sound():
	$WalkCh.play()
	
func play_DamageCh_sound():
	$DamageCh.play()
	
func play_PointUpCh_sound():
	$PointUpCh.play()

func play_RunningCh_sound():
	$RunningCh.play()
	
func play_Tonext_sound():
	$Tonext.play()
	
func play_Noteflip_sound():
	$Noteflip.play()

func play_Closebutton_sound():
	$CloseButton.play()
	
func play_Smallclick_sound():
	$Smallclick.play()
	
func play_Normalfileclick_sound():
	$Normalfileclick.play()

func play_Trashfileclick_sound():
	$Trashfileclick.play()

func play_Erasefile_sound():
	$Erasefile.play()

func play_Waterclean_sound():
	$Waterclean.play()
	
func play_Mopping_sound():
	$Mopping.play()
	
func play_Typing_sound():
	$Typing.play()
	
func play_Worddelete_sound():
	$Worddelete.play()
	
func play_Coffeefall_sound():
	$Coffeefall.play()
	
func play_Sugarfall_sound():
	$Sugarfall.play()

func play_Primfall_sound():
	$Primfall.play()
	
func play_Waterfall_sound():
	$Waterfall.play()
	
	
#Junsang 추가 사운드 부분 함수
func play_order_sound():
	$Order.play()

func play_menu_upload_sound():
	$MenuUpload.play()
	
func play_count_down_sound():
	print("play all count down")
	$CountDown.play()
