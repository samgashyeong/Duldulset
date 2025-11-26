extends SubViewportContainer

@onready var coffee_machine = $"../Map/CoffeeMaker"

func _ready():
	hide()
	coffee_machine.coffee_making.connect(_on_coffee_machine_coffee_making)
	

func _on_coffee_machine_coffee_making():
	show()
