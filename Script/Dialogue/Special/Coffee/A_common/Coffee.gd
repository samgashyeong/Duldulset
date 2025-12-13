#202322158 이준상
#Define CoffeeOrder
extends Resource
class_name Coffee

#load CoffeeOrder Class
const CoffeeOrder = preload("res://Script/Dialogue/Special/Coffee/A_common/CoffeeOrder.gd")


@export var orders : Array[CoffeeOrder]
