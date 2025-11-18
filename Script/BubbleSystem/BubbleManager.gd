extends Node


@onready var bubbleText = preload("res://Scene/BubbleText/BubbleText.tscn")
@onready var coffeeDialog = preload("res://Script/Dialogue/Special/Coffee/Chunja/ChunjaCoffee.tres")

var dialogLine : Array[String] = []
var currentLine = 0

var textBox
var textBoxPosition

var isDialogActive = false
var canAdvanceLine = false


func startDialog(position : Vector2, line : Array[String]):
	if isDialogActive:
		return
	
	dialogLine = line
	textBoxPosition = position
	showTextBox()
	
	
	
func showTextBox():
	textBox = bubbleText.instantiate()
	
	textBox.finishDisplay.connect(onTextBoxFinishedDisplay)
	get_tree().root.add_child(textBox)
	
	textBox.global_position = textBoxPosition
	textBox.textToDisPlay("애국가 동해물가 백두산이 마르고 닳도록 하느님이 보우하사 우리나라만세")
	canAdvanceLine = false
	
	
func onTextBoxFinishedDisplay():
	canAdvanceLine = true
	
