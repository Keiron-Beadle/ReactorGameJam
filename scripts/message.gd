extends Control

func set_message(msg):
	get_node("TextureRect/Message").text = msg

func set_voice(voice_file):
	if voice_file == null:
		$AudioStreamPlayer.stream = null
	else:
		var stream = load("res://assets/" + voice_file)
		$AudioStreamPlayer.stream = stream

func _ready():
	get_node("TextureRect/Quit").button_up.connect(_quit)
	$AudioStreamPlayer.play()
	
func _quit():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	queue_free()
