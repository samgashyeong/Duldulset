#202221035현동우
extends Panel 

func _ready():
	pass

#음량조절(control audio volume)
func _on_audiocontrol_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	
	var volume_linear = value / 100.0
	
	if value == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_linear))

#밝기조절(control brightness using globallight(autoloaded))
func _on_brightcontrol_value_changed(value: float) -> void:
	var brightness = value /100.0
	GlobalLight.color = Color(brightness, brightness, brightness, 1)
