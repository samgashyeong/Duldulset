#202322158 이준상
extends RichTextLabel

var max_lines = 10
var log_history = []


@onready var employee = $"../../NPC/Employee"

@onready var bubbleText : Array[Control]

@onready var player = $"../../Giiyoung"

@onready var clock = $"../ClockSystem"
func _ready() -> void:
	
	for i in employee.get_children().size():
		var _employ = employee.get_child(i)
		_employ.addLog.connect(receiveLog)
		_employ.addBubble.connect(connectBubble)
		
	player.point_changed.connect(receiveInformationLog)
	player.stamina_changed.connect(receiveInformationLog)
	player.health_changed.connect(receiveInformationLog)
	
	var targetnode = clock.get_child(1).get_child(0)
	
	targetnode.changeClock.connect(changeClockLog)
	

func connectBubble(bubble : Control):
	bubbleText.append(bubble)
	print("bubble connect")
	bubble.addLog.connect(receiveLog)

func receiveInformationLog(type : Type.LOG, changeInformation : int):
	match type:
		Type.LOG.POINT:
			add_log("You get " + str(changeInformation) + " points!!")
		Type.LOG.HEALTH:
			if(changeInformation < 0):
				add_log("You get " + str(changeInformation) + "health!!")
			else:
				add_log("You lose" +  str(changeInformation)+ "health...")
		Type.LOG.STAMIA:
			if(changeInformation < 0):
				add_log("You get " + str(changeInformation) + "stamia!!")
			else:
				add_log("You lose" +  str(changeInformation)+ "stamia.")

func changeClockLog(time : int):
	add_log("The current time is " +str(time)+ " o'clock!")
	
			
func receiveLog(type : Type.LOG, staff : Type.StaffName):
	print("receiveLog : " + str(type))
	match type:
		Type.LOG.ORDER:
			add_log(Type.StaffName.keys()[staff] + " ordered coffee from you!!")
		Type.LOG.STAFF_ANGRY_NOT_ORDER:
			add_log("One of the staff was angry because you didn't take orders for coffee...")
		Type.LOG.STAFF_ANGRY_NOT_MAKE_COFFEE:
			add_log("One of the staff was angry because you didn't make the coffee...")

#add log
func add_log(message : String):
	log_history.append(message)
	
	if log_history.size() > max_lines:
		log_history.pop_front()
	
	text = "\n".join(log_history)
