class_name Sugar extends RigidBody2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if (body.collision_layer & 4) != 0:
		GameData.sugar_count -= 1
		print("현재 설탕 개수: ", GameData.sugar_count)
		queue_free()
