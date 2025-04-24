extends Control

@export var reactor_button_scene : PackedScene

var reactor_object = preload("res://scripts/reactor_object.gd")

var reactors_button
var time_label
var time = 9
var overview
var day_over = false
var control_rod_text
@onready var temp_graph = $ReactorOverview/TemperatureGraph
@onready var power_graph = $ReactorOverview/PowerOutputGraph
@onready var entropy_graph = $ReactorOverview/EntropyGraph

@onready var total_power_graph = $PowerOutput/TotalPowerGraph
@onready var total_power_label = $PowerOutput/TotalPowerLabel
@onready var num_reactors_label = $PowerOutput/NumReactorsLabel

@onready var status_container = $ControlPanel/StatusContainer
@onready var increase_control = $ControlPanel/IncreaseControl
@onready var decrease_control = $ControlPanel/DecreaseControl

@onready var money_label = $Shop/MoneyLabel
@onready var buy_fuel = $Shop/BuyFuel
@onready var buy_coolant = $Shop/BuyCoolant
@onready var fuel_price_label = $Shop/FuelPriceLabel
@onready var coolant_price_label = $Shop/CoolantPriceLabel

@onready var population_demand_chart = $Demands/PopulationDemand
@onready var power_demand_chart = $Demands/PowerDemand
@onready var population_demand_label = $Demands/PopulationDemand/Label
@onready var power_demand_label = $Demands/PowerDemand/Label

@onready var abort_button = $ControlPanel/AbortButton

@onready var day_timer = $DayTimer
@onready var app_close_timer = $AppCloseTimer
@onready var app_close_sound = $AppCloseSound
@onready var reactor_voice = $ReactorVoice

@onready var tutorial = $Tutorial
@onready var tutorial1 = $Tutorial1
@onready var tutorial2 = $Tutorial2
@onready var tutorial3 = $Tutorial3
@onready var tutorial4 = $Tutorial4
@onready var tutorial5 = $Tutorial5
@onready var tutorial6 = $Tutorial6
@onready var tutorial7 = $Tutorial7
@onready var tutorial8 = $Tutorial8

var target_power = 0.0
var MONEY_PER_EXTRA_POWER = 50.0
var MONEY_LOSS_PER_MISSING_POWER = 20.0

var total_power_history = []
var reactor_save_data_timer = 1.0
var ignore_money_ticks = 10

var uranium_price = 94.0
var plutonium_price = 120.0
var coolant_price = 64.0

var reactors
var active_reactor

func _ready():
	reactors_button = $Taskbar/ReactorButtons
	time_label = $Taskbar/ColorRect/Time
	overview = $ReactorOverview/Overview
	control_rod_text = $ControlPanel/ControlRodInsertion
	increase_control.button_up.connect(_increase_control_rod)
	decrease_control.button_up.connect(_decrease_control_rod)

	abort_button.button_up.connect(_abort_reactor)

	buy_fuel.button_up.connect(_on_buy_fuel)
	buy_coolant.button_up.connect(_on_buy_coolant)
	coolant_price_label.text = '$%d /25' % coolant_price

	var hour_seconds = 7.5 if GameData.day_length == '1 Min' else 15 if GameData.day_length == '2 Min' else 22.5 if GameData.day_length == '3 Min' else 30
	day_timer.wait_time = hour_seconds
	day_timer.timeout.connect(_on_hour_elapsed)
	day_timer.start()
	app_close_timer.timeout.connect(_on_app_close)

	for i in range(64):
		total_power_history.append(0)

	reactors = []
	
	for i in range(GameData.day_ptr+1):
		var reactor_obj = reactor_object.new()
		reactor_obj.from_dict(GameData.reactors[i])
		reactors.append(reactor_obj)
		reactor_obj.meltdown_warning_on.connect(_on_reactor_near_meltdown)
		reactor_obj.meltdown_warning_off.connect(_on_reactor_leave_meltdown)
		reactor_obj.meltdown.connect(_on_reactor_meltdown)
		reactor_obj.add_meltdown_timer_to_scene(self)
		
		var reactor_button = reactor_button_scene.instantiate()
		reactor_button.set_reactor(reactor_obj)
		reactor_button.clicked.connect(_on_click_reactor)
		reactors_button.add_child(reactor_button)
		
	for i in range(GameData.day_ptr + 1, len(GameData.reactors)):
		status_container.get_child(i).modulate = Color(0.5,0.5,0.5,1)
	
	target_power = GameData.demands[GameData.day_ptr]
	money_label.text = "$%.2f" % GameData.money
	num_reactors_label.text = "%d Reactors" % len(reactors)
	navigate_reactor(reactors[0])

	var texture_unit = load("res://assets/vertical_progress_unit.png")
	
	population_demand_chart.set_progress(20.1 * (GameData.day_ptr + 1))
	population_demand_label.text = "%s people" % GameData.people[GameData.day_ptr]
	population_demand_chart.set_texture(texture_unit)

	power_demand_chart.set_progress(0.0)
	power_demand_label.text = "%.2f MW/s" % GameData.demands[GameData.day_ptr]
	power_demand_chart.set_texture(texture_unit)
	time_label.text = "%d:00" % time
	
	if not GameData.seen_tutorial:
		Engine.time_scale = 0.0
		tutorial.visible = true
		tutorial1.visible = true
		tutorial1.next_tutorial.connect(func(): tutorial2.visible = true)
		tutorial2.next_tutorial.connect(func(): tutorial3.visible = true)
		tutorial3.next_tutorial.connect(func(): tutorial4.visible = true)
		tutorial4.next_tutorial.connect(func(): tutorial5.visible = true)
		tutorial5.next_tutorial.connect(func(): tutorial6.visible = true)
		tutorial6.next_tutorial.connect(func(): tutorial7.visible = true)
		tutorial7.next_tutorial.connect(func(): tutorial8.visible = true)
		tutorial8.next_tutorial.connect(_end_tutorial)
		tutorial1.tutorial_cancelled.connect(_end_tutorial)
		tutorial2.tutorial_cancelled.connect(_end_tutorial)
		tutorial3.tutorial_cancelled.connect(_end_tutorial)
		tutorial4.tutorial_cancelled.connect(_end_tutorial)
		tutorial5.tutorial_cancelled.connect(_end_tutorial)
		tutorial6.tutorial_cancelled.connect(_end_tutorial)
		tutorial7.tutorial_cancelled.connect(_end_tutorial)
		tutorial8.tutorial_cancelled.connect(_end_tutorial)
		
		tutorial1.set_text("Hello and welcome to your Nuclear Reactor overseer software solution!\n\nThis is a tutorial, if you'd like to cancel it, press the X at the top-right.")
		tutorial2.set_text("Above, you'll find the Shop. This is where you can purchase Coolant & Fuel for the reactors you manage.")
		tutorial3.set_text("Behind me, you'll find a graph that indicates\nA) The number of clients you're servicing with your reactors\nB) The total energy they require, the bar will fill up to show you your progress in meeting this requirement.")
		tutorial4.set_text("Above, you'll find a graph of the total power output of the facility, i.e. the sum of your reactors power output.")
		tutorial5.set_text("This is the active reactor overview panel -- it'll show you the temperature, power output, entropy, coolant & fuel levels, and other tidbits of the reactor you're looking at.\n\nWatch it carefully: As if you're life depends on it.")
		tutorial6.set_text("Below you'll find the control panel, you can control the selected reactor's Control Rod Insertion value, 0% means they're fully out.\nAlso, there is an ABORT button. This will shut the reactor down completely, but no more money will be earned from this reactor for the rest of the day.")
		tutorial7.set_text("At the bottom right corner you'll find the current time - days run from 9AM to 5PM. Make the most of your time: You have about %s of real-world time." % GameData.day_length)
		tutorial8.set_text("The taskbar will contains tabs for each reactor you manage.\nClicking one of the tabs will select it, and let you control it.\n\nMonitor them all wisely and closely, or risk meltdown.\n\nGot it? This is the tutorial over.")
		
func _end_tutorial():
	Engine.time_scale = 1.0
	tutorial.visible = false
	GameData.seen_tutorial = true

func _abort_reactor():
	active_reactor.shutdown_reactor()
	abort_button.disabled = true
	increase_control.disabled = true
	decrease_control.disabled = true
	control_rod_text.text = "100%"

func _on_hour_elapsed():
	time += 1
	time_label.text = "%d:00" % time
	if time == 17:
		day_timer.stop()
		day_over = true
		GameData.day_ptr += 1
		app_close_timer.start()

func _on_app_close():
	if population_demand_chart.get_parent().visible:
		population_demand_chart.get_parent().visible = false
		app_close_sound.play()
		return
	if money_label.get_parent().visible:
		money_label.get_parent().visible = false
		app_close_sound.play()
		return
	if total_power_graph.get_parent().visible:
		total_power_graph.get_parent().visible = false;
		app_close_sound.play()
		return
	if temp_graph.get_parent().visible:
		temp_graph.get_parent().visible = false;
		app_close_sound.play()
		return
	
	if GameData.day_ptr == 5:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/desktop.tscn")

func _on_reactor_near_meltdown(melting_down_reactor):
	for i in range(len(reactors)):
		if reactors[i] == melting_down_reactor and (not melting_down_reactor.tween or not melting_down_reactor.tween.is_valid()):
			var status_texture : TextureRect = status_container.get_child(i)
			status_texture.texture = load("res://assets/reactor_status_on.png")
			
			melting_down_reactor.tween = create_tween()
			melting_down_reactor.tween.set_loops()  # Loop indefinitely
			melting_down_reactor.tween.tween_property(status_texture, "modulate", Color.DIM_GRAY, 0.5)
			melting_down_reactor.tween.tween_property(status_texture, "modulate", Color.WHITE, 0.5)
			
			if not reactor_voice.playing:
				reactor_voice.play()

func _on_reactor_leave_meltdown(saved_reactor):
	for i in range(len(reactors)):
		if reactors[i] == saved_reactor:
			var status_texture : TextureRect = status_container.get_child(i)
			status_texture.texture = load("res://assets/reactor_status_off.png")
			status_texture.modulate = Color.WHITE
			saved_reactor.tween.kill()
	
func _on_reactor_meltdown(reactor):
	var reason = "%s Meltdown" % reactor.name
	game_over(reason)
	
func game_over(reason):
	GameData.game_result = reason
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _increase_control_rod():
	if active_reactor:
		active_reactor.increase_control(5)
		var text = "%d%%" % int(active_reactor.control_rod_insertion)
		control_rod_text.text = text
	
func _decrease_control_rod():
	if active_reactor:
		active_reactor.decrease_control(5)
		var text = "%d%%" % int(active_reactor.control_rod_insertion)
		control_rod_text.text = text

func navigate_reactor(reactor):
	active_reactor = reactor
	overview.set_reactor(active_reactor)
	var text = "%d%%" % int(active_reactor.control_rod_insertion)
	control_rod_text.text = text
	fuel_price_label.text = ('$%d /25' % uranium_price) if reactor.fuel_type == 'Uranium' else ('$%d /25' % plutonium_price)
	abort_button.disabled = active_reactor.aborted
	increase_control.disabled = active_reactor.aborted
	decrease_control.disabled = active_reactor.aborted
	
	temp_graph.set_points(active_reactor.temp_history)
	temp_graph.set_label("%d" % (active_reactor.temperature + 273))
	power_graph.set_points(active_reactor.power_history)
	power_graph.set_label("%.2f" % active_reactor.power_output)
	entropy_graph.set_points(active_reactor.entropy_history)
	entropy_graph.set_label("%d%%" % (active_reactor.entropy_level * 100.0))

func _process(dt):
	if day_over:
		return
	
	var should_save = reactor_save_data_timer <= 0.0

	var total_power = 0.0
	for reactor in reactors:
		reactor.tick(dt, should_save)
		overview.update_stats()
		total_power += reactor.power_output
	
	total_power_label.text = "%.2f MW/s" % total_power

	if should_save:
		total_power_history.pop_front()
		total_power_history.append(0)
		for reactor in reactors:
			total_power_history[-1] += reactor.power_output
		
		total_power_graph.set_points(total_power_history)
		temp_graph.set_points(active_reactor.temp_history)
		temp_graph.set_label("%d" % (active_reactor.temperature + 273))
		power_graph.set_points(active_reactor.power_history)
		power_graph.set_label("%.2f" % active_reactor.power_output)
		entropy_graph.set_points(active_reactor.entropy_history)
		entropy_graph.set_label("%d%%" % (active_reactor.entropy_level * 100.0))
		reactor_save_data_timer = 1.0
		
		var max_power_demand = GameData.demands[GameData.day_ptr]
		var prg = min(100.1, (total_power_history.back() / max_power_demand) * 100.0)
		power_demand_chart.set_progress(prg)
		
		ignore_money_ticks -= 1
		if ignore_money_ticks < 0:
			if total_power_history.back() < target_power:
				GameData.money -= MONEY_LOSS_PER_MISSING_POWER * (target_power - total_power_history.back())
				if GameData.money <= 0.0:
					game_over("Bankrupt")
			else:
				GameData.money += MONEY_PER_EXTRA_POWER * (total_power_history.back() - target_power)
			money_label.text = "$%.2f" % GameData.money
	else:
		reactor_save_data_timer -= dt

func _on_buy_fuel():
	var fuel_price = uranium_price if active_reactor.fuel_type == 'Uranium' else plutonium_price
	if GameData.money < fuel_price:
		return
	var fuel_delta = min(25, 100 - active_reactor.fuel_level)
	GameData.money -= fuel_price * (fuel_delta / 25.0)
	active_reactor.add_fuel(fuel_delta)
	money_label.text = "$%.2f" % GameData.money
	
func _on_buy_coolant():
	if GameData.money < coolant_price:
		return
	var coolant_delta = min(0.25, 1.0 - active_reactor.coolant_level)
	GameData.money -= coolant_price * (coolant_delta / 0.25)
	active_reactor.add_coolant(coolant_delta)
	money_label.text = "$%.2f" % GameData.money

func _on_click_reactor(reactor):
	navigate_reactor(reactor)
