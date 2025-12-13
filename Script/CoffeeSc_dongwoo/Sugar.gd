#202221035 현동우
class_name Sugar extends RigidBody2D

func _ready():
	# 충돌 감지 신호를 함수에 연결 (Connect the collision detection signal to the function)
	body_entered.connect(_on_body_entered)

#책상과 부딪히면 설탕 갯수 감소 및 삭제(when hit the desk, the number of sugars decreases and is deleted)
func _on_body_entered(body: Node):
	if (body.collision_layer & 4) != 0:
		GameData.sugar_count -= 1
		print("현재 설탕 개수: ", GameData.sugar_count)
		queue_free()
