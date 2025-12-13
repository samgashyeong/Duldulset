#202322158 이준상
#Define Use CoffeeOrder Data Element
extends Resource
class_name CoffeeOrder

@export var dialog : String
@export var coffee : int
@export var cream : int
@export var sugar : int
@export var isAction : bool = false
@export var isCoffeeClear : bool = true
@export var isCreamClear : bool = false
@export var isSugarClear : bool = false
