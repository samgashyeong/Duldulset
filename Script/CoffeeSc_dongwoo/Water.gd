#202221035 현동우
class_name Water extends RigidBody2D

func _ready():
	body_entered.connect(_on_body_entered)

#책상과 닿으면 삭제(delte when hit the desk)
func _on_body_entered(body: Node):
	if (body.collision_layer & 4) != 0:
		queue_free() 
