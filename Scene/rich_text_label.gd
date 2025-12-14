#202322158 이준상
# This file manages and displays game logs in a RichTextLabel.


extends RichTextLabel

# Maximum number of lines to display in the log.
var max_lines = 10
# Stores the history of log messages.
var log_history = []


# Get a reference to the Employee node (NPCs).
@onready var employee = $"../../NPC/Employee"

# Array to hold references to Control nodes (likely speech bubbles).
@onready var bubbleText : Array[Control]

# Get a reference to the Player node.
@onready var player = $"../../Giiyoung"

# Get a reference to the ClockSystem node.
@onready var clock = $"../ClockSystem"
func _ready() -> void:
	
	# Iterate through all child nodes of the employee container.
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		# Connect the 'addLog' signal from each employee to the 'receiveLog' function.
		_employ.addLog.connect(receiveLog)
		# Connect the 'addBubble' signal from each employee to the 'connectBubble' function.
		_employ.addBubble.connect(connectBubble)
		
	# Connect player signals to log functions.
	# Connect 'point_changed' signal to log point changes.
	player.point_changed.connect(func(new_value, change): receiveInformationLog(Type.LOG.POINT, change))
	# Connect 'stamina_changed' signal to log stamina changes.
	player.stamina_changed.connect(func(new_value, change): receiveInformationLog(Type.LOG.STAMIA, change))
	# Connect 'health_changed' signal to log health changes.
	player.health_changed.connect(func(new_value, change): receiveInformationLog(Type.LOG.HEALTH, change))
	
	# Get the specific node responsible for emitting the clock change signal.
	var targetnode = clock.get_child(1).get_child(0)
	
	# Connect the 'changeClock' signal to the 'changeClockLog' function.
	targetnode.changeClock.connect(changeClockLog)
	

# Connects a speech bubble control to the log system.
func connectBubble(bubble : Control):
	# Add the bubble control to the bubbleText array.
	bubbleText.append(bubble)
	# Print a debug message.
	print("bubble connect")
	# Connect the 'addLog' signal from the bubble to the 'receiveLog' function.
	bubble.addLog.connect(receiveLog)

# Receives and processes log information related to player stats changes.
func receiveInformationLog(type : Type.LOG, changeInformation : int):
	# Handle the log based on the type of information changed.
	match type:
		Type.LOG.POINT:
			# Log gaining points.
			add_log("You get " + str(changeInformation) + " points!!")
		Type.LOG.HEALTH:
			# Log health changes.
			if(changeInformation > 0):
				# Log gaining health.
				add_log("You get " + str(changeInformation) + "health!!")
			else:
				# Log losing health.
				add_log("You lose" + str(changeInformation)+ "health...")
		Type.LOG.STAMIA:
			# Stamina logging is currently commented out/placeholder.
			pass
			#else:
				#add_log("You lose" + str(changeInformation)+ "stamia.")

# Logs the current game time when the clock changes.
func changeClockLog(time : int):
	add_log("The current time is " +str(time)+ " o'clock!")
	
			
# Receives and processes general log events (e.g., staff interactions).
func receiveLog(type : Type.LOG, staff : Type.StaffName):
	# Print the received log type for debugging.
	print("receiveLog : " + str(type))
	# Handle the log based on the type of event.
	match type:
		Type.LOG.ORDER:
			# Log a staff member ordering coffee.
			add_log(Type.StaffName.keys()[staff] + " ordered coffee from you!!")
		Type.LOG.STAFF_ANGRY_NOT_ORDER:
			# Log staff anger due to missed order.
			add_log("One of the staff was angry because you didn't take orders for coffee...")
		Type.LOG.STAFF_ANGRY_NOT_MAKE_COFFEE:
			# Log staff anger due to coffee not being made.
			add_log("One of the staff was angry because you didn't make the coffee...")

# Function to add a new message to the log history and update the display.
func add_log(message : String):
	# Append the new message to the history.
	log_history.append(message)
	
	# If the history exceeds the maximum lines, remove the oldest message.
	if log_history.size() > max_lines:
		log_history.pop_front()
	
	# Join the log history messages with separators and update the RichTextLabel text.
	text = "\n-----\n".join(log_history)
