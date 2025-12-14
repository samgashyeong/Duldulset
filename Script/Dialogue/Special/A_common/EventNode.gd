#202322158 이준상
#In the end, I didn't use this file.

extends Resource


const Choice = preload("res://Script/Dialogue/Special/A_common/Choice.gd")
const Outcome = preload("res://Script/Dialogue/Special/A_common/Outcome.gd")
@export var speaker : String
@export var dialogue : Resource
@export var choices : Array[Choice]
@export var choicesSecond : int = -1
@export var nextNode : Resource
@export var finishOutCome : Resource
