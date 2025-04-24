extends Object

var fuel_type
var name
var bio
var tween
var aborted = false
var near_meltdown = false
var max_output = 1.5
var power_output = 0.0
var entropy_level = 0.0
var temperature = 1.0
var critical_entropy = 150.0
var critical_temperature
var fuel_level = 50.0  # Full fuel level (as a percentage)
var coolant_level = 1.0  # Full coolant level (as a percentage)
var control_rod_insertion = 75  # Mostly done initially
var generation_rate = 0.0  # Energy output

var temp_history = []
var power_history = []
var entropy_history = []

var HEAT_PER_ENERGY_UNIT = 0.01
var ENERGY_CONSUMED_PER_UNIT_FUEL  # Amount of energy per unit of fuel
var COOLANT_EFFECTIVENESS  # Coolant decreases temperature at this rate
var CONTROL_ROD_EFFECTIVENESS  # Control rods reduce energy output

var meltdown_timer = Timer.new()

signal meltdown
signal meltdown_warning_on
signal meltdown_warning_off

func get_sprite():
	if fuel_type == 'Uranium':
		return ''
	if fuel_type == 'Plutonium':
		return ''
	false

func from_dict(indict):
	var difficulty_multiplier = 1.0 if GameData.difficulty == 'Normal' else 1.2
	fuel_type = indict['fuel']
	max_output = indict['max_output']
	name = indict['name']
	bio = indict['bio']
	critical_entropy = indict['critical_entropy'] * difficulty_multiplier
	critical_temperature = indict['critical_temp'] * difficulty_multiplier
	ENERGY_CONSUMED_PER_UNIT_FUEL = indict['energy_consumed_per_unit_fuel']
	COOLANT_EFFECTIVENESS = indict['coolant_effectiveness'] * difficulty_multiplier
	CONTROL_ROD_EFFECTIVENESS = indict['control_rod_effectiveness'] * difficulty_multiplier
	
	meltdown_timer.timeout.connect(_on_meltdown)
	
	for i in range(64):
		temp_history.append(0)
		power_history.append(0)
		entropy_history.append(0)
	
func _on_meltdown():
	meltdown.emit(self)

func add_meltdown_timer_to_scene(node):
	node.add_child(meltdown_timer)

func tick(dt, save_data = false):
	if aborted:
		return
	
	#  Energy Generation Based on Fuel & Control Rods
	generation_rate = fuel_level * ENERGY_CONSUMED_PER_UNIT_FUEL * (1 - control_rod_insertion * 0.01) * dt

	# Entropy Grows from Energy Output
	entropy_level += generation_rate * HEAT_PER_ENERGY_UNIT * dt
	entropy_level = max(0, entropy_level - control_rod_insertion * 0.01 * CONTROL_ROD_EFFECTIVENESS * dt) # Control Rods Reduce Entropy

	# Temperature Increases from Entropy
	temperature += entropy_level * dt * 100.0

	# Coolant Reduces Temperature, but Less Effective at High Temps
	if coolant_level > 1e-2:
		var coolant_effect = min(coolant_level, temperature * COOLANT_EFFECTIVENESS * dt)
		temperature -= coolant_effect
		
		var coolant_drain_rate = (1.0 - (coolant_level / 100.0)) * 1e-2
		coolant_level = max(0, coolant_level - coolant_drain_rate * dt)
	else:
		temperature += dt  + entropy_level * 0.05 * dt  # Without coolant, temperature rises faster

	#  Fuel is Consumed Over Time
	fuel_level = max(0, fuel_level - generation_rate * dt * 0.25)

	power_output = min(max_output, temperature / 100.0)

	#  Check for Meltdown
	if entropy_level > critical_entropy or temperature > critical_temperature:
		if meltdown_timer.is_stopped():
			meltdown_warning_on.emit(self)
			near_meltdown = true
			meltdown_timer.wait_time = randi_range(5,15)
			meltdown_timer.start()
	elif near_meltdown:
		meltdown_warning_off.emit(self)
		near_meltdown = false
		meltdown_timer.stop()
		
	if save_data:
		temp_history.pop_front()
		temp_history.append(temperature)
		
		entropy_history.pop_front()
		entropy_history.append(entropy_level)
		
		power_history.pop_front()
		power_history.append(power_output)

func add_fuel(amount):
	fuel_level = min(100, fuel_level + amount)

func add_coolant(amount):
	coolant_level = min(1.0, coolant_level + amount)

func increase_control(amount):
	control_rod_insertion = min(100, control_rod_insertion + amount)

func decrease_control(amount):
	control_rod_insertion = max(0, control_rod_insertion - amount)

# Shut down the reactor for the day (stopping it from generating money)
func shutdown_reactor():
	aborted = true
	fuel_level = 0
	coolant_level = 0
	temperature = 0.0
	power_output = 0.0
	entropy_level = 0.0
	control_rod_insertion = 100  # Insert all rods to stop reaction
	generation_rate = 0
	temp_history.pop_front()
	temp_history.append(0)
	power_history.pop_front()
	power_history.append(0)
	entropy_history.pop_front()
	entropy_history.append(0)
	
	if near_meltdown:
		meltdown_warning_off.emit(self)
		near_meltdown = false
		meltdown_timer.stop()
