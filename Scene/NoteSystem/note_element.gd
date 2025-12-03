#202322158 이준상

extends VBoxContainer


func setData(coffeeOrder : CoffeeOrder):
	
	var coffeeDialog = "????"
	var coffee = "?"
	var sugar = "?"
	var cream = "?"
	
	if(coffeeOrder.isAction):
		coffeeDialog = coffeeOrder.dialog
	if(coffeeOrder.isCoffeeClear):
		coffee = str(coffeeOrder.coffee)
	if(coffeeOrder.isCreamClear):
		sugar = str(coffeeOrder.cream)
	if(coffeeOrder.isSugarClear):
		cream = str(coffeeOrder.sugar)
		
	$Label.text = coffeeDialog
	$HBoxContainer/Label.text = coffee
	$HBoxContainer/Label2.text = cream
	$HBoxContainer/Label3.text = sugar
	
	
