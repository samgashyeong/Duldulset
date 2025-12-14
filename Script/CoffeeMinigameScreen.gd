# 202322111 임상인
# This script is for managing the coffee minigame screen.

extends SubViewportContainer

@onready var coffee_machine = $"../../../Map/CoffeeMaker"
@onready var coffee_scene_resource_location = preload("res://Scene/coffee_dongwoo/CoffeeMainScene.tscn")
var coffee_scene = null

# It initializes.
func _ready():
	# hide the popup screen at first
	hide()
	
	# connect the signal of the coffee maker object
	coffee_machine.coffee_making.connect(_on_coffee_machine_coffee_making)


# It handles when the Player is making a coffee using the coffee maker object.
func _on_coffee_machine_coffee_making():
	# instantiate the coffee scene and do settings
	coffee_scene = coffee_scene_resource_location.instantiate()
	coffee_scene.coffee_finished.connect(_on_coffee_scene_coffee_finished)
	$"SubViewport".add_child(coffee_scene)
	
	# show the popup screen
	show()
	
	# reset coffee states
	GameData.coffee_count = 0
	GameData.prim_count = 0
	GameData.sugar_count = 0
	
	#emit signal : junsang
	GameData.add_coffee.emit(0)
	GameData.add_sugar.emit(0)
	GameData.add_cream.emit(0)

# It handles when the coffee making is finished.
func _on_coffee_scene_coffee_finished():
	# hide the popup screen
	hide()
	
	# update states
	GameData.is_coffee_ready = true
	GameData.is_playing_minigame = false
	coffee_scene = null
