#202322158 이준상
# This file manages a single Note Element UI, displaying the status and details of a specific coffee order.


extends VBoxContainer


# Function to set the data and update the labels of the note element.
func setData(coffeeOrder : CoffeeOrder):
	
	# Initialize variables for display text.
	var coffeeDialog = "????"
	var coffee = "?"
	var sugar = "?"
	var cream = "?"
	
	# Check if the order is currently active/in action.
	if(coffeeOrder.isAction):
		# If active, display the staff's dialogue for the order.
		coffeeDialog = coffeeOrder.dialog
	# Check if the coffee requirement for this order has been successfully met (cleared).
	if(coffeeOrder.isCoffeeClear):
		# If cleared, display the required coffee amount.
		coffee = str(coffeeOrder.coffee)
	# Check if the cream requirement for this order has been successfully met (cleared).
	if(coffeeOrder.isCreamClear):
		# If cleared, display the required cream amount.
		cream = str(coffeeOrder.cream)
	# Check if the sugar requirement for this order has been successfully met (cleared).
	if(coffeeOrder.isSugarClear):
		# If cleared, display the required sugar amount.
		sugar = str(coffeeOrder.sugar)
		
	# Update the main dialogue label.
	$Label.text = coffeeDialog
	# Update the coffee amount label.
	$HBoxContainer/Label.text = coffee
	# Update the cream amount label.
	$HBoxContainer/Label2.text = cream
	# Update the sugar amount label.
	$HBoxContainer/Label3.text = sugar
