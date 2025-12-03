extends SubViewportContainer

@onready var coffee_machine = $"../../Map/CoffeeMaker"
@onready var coffee_scene_resource_location = preload("res://Scene/coffee_dongwoo/CoffeeMainScene.tscn")
var coffee_scene = null

func _ready():
	hide()
	coffee_machine.coffee_making.connect(_on_coffee_machine_coffee_making)
	
	#coffee_scene.coffee_finished.connect(_on_coffee_scene_coffee_finished)
	

func _on_coffee_machine_coffee_making():
	coffee_scene = coffee_scene_resource_location.instantiate()
	coffee_scene.coffee_finished.connect(_on_coffee_scene_coffee_finished)
	$"SubViewport".add_child(coffee_scene)
	
	show()
	GameData.coffee_count = 0
	GameData.prim_count = 0
	GameData.sugar_count = 0

func _on_coffee_scene_coffee_finished():
	hide()
	GameData.is_coffee_ready = true
	GameData.is_playing_minigame = false
	coffee_scene = null
