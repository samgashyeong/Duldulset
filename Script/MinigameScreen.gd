extends SubViewportContainer

@onready var coffee_machine = $"../Map/CoffeeMaker"
@onready var minigame_scene = $SubViewport/CoffeeMainScene

func _ready():
	hide()
	coffee_machine.coffee_making.connect(_on_coffee_machine_coffee_making)
	
	if minigame_scene:
		if not minigame_scene.minigame_finished.is_connected(_on_minigame_finished):
			minigame_scene.minigame_finished.connect(_on_minigame_finished)

func _on_coffee_machine_coffee_making():
	show()

func _on_minigame_finished():
	get_tree().paused = false
	hide()
   
