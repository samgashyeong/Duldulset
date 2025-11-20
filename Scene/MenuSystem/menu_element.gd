extends MarginContainer


var order : CoffeeMenu

@onready var staff = $MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var orderDis = $MarginContainer/VBoxContainer/Label

func _ready():
	# 시작할 때 투명하게 설정
	modulate.a = 0.0

func setData(menu : CoffeeMenu):
	staff = $MarginContainer/VBoxContainer/HBoxContainer/Label2
	orderDis = $MarginContainer/VBoxContainer/Label
	order = menu
	print(menu.staff)
	staff.text = menu.staff
	orderDis.text = menu.dialog
	

func play_appear_animation():
	var anim_player = $AnimationPlayer # 경로 확인
	
	# 이미 플레이어가 있다면
	if anim_player:
		# 애니메이션 시작 전에 투명하게 설정
		modulate.a = 0.0
		anim_player.stop()
		anim_player.play("new_animation")
