extends Control

var reactor

func set_reactor(in_reactor):
	reactor = in_reactor
	update_stats()
	
func update_stats():
	$Name.text = "System: %s" % reactor.name
	#$Temperature.text = "Temp: %d K" % (273 + reactor.temperature)
	$Fuel.text = "Fuel: %d" % reactor.fuel_level
	$Coolant.text = "Coolant: %d%%" % (reactor.coolant_level * 100.0)
	#$Entropy.text = "Entropy: %d%%" % (reactor.entropy_level * 100.0)
	#$Generation.text = "Power: %.2f MW" % reactor.power_output
	$Bio.text = reactor.bio
	#$ControlRod.text = "Rods: %d%%" % reactor.control_rod_insertion

func get_reactor():
	return reactor
