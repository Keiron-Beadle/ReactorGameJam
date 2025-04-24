extends Node2D

var elapsed
var each_dot_delay

func _ready():
	elapsed = 0.0
	
	each_dot_delay = ($AudioStreamPlayer.stream.get_length() - 1) / 3
	$BootTimer.wait_time = $AudioStreamPlayer.stream.get_length()
	$BootTimer.start()
	$BootTimer.timeout.connect(_on_booted)
	
	$FirstDot.visible = false
	$SecondDot.visible = false
	$ThirdDot.visible = false
	
func _process(dt):
	elapsed += dt
	if elapsed > each_dot_delay and not $FirstDot.visible:
		$FirstDot.visible = true
		
	if elapsed > each_dot_delay * 2 and not $SecondDot.visible:
		$SecondDot.visible = true
		
	if elapsed > each_dot_delay * 3 and not $ThirdDot.visible:
		$ThirdDot.visible = true
	
func _on_booted():
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")
