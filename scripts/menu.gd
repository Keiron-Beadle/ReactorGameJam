extends Control

@export var boot_scene : PackedScene
@export var options_scene : PackedScene

func _ready():
	$StartButton.button_up.connect(_on_start)
	$OptionsButton.button_up.connect(_on_options)
	$QuitButton.button_up.connect(_on_exit)
	
func _on_start():
	get_tree().change_scene_to_packed(boot_scene)
	
func _on_options():
	get_tree().change_scene_to_packed(options_scene)
	
func _on_exit():
	get_tree().quit()
