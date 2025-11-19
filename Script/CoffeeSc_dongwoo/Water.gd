class_name Water extends RigidBody2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if (body.collision_layer & 4) != 0:
		queue_free() 
