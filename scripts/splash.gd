extends Control

@export var menu_scene : PackedScene

func _ready():
	$Timer.timeout.connect(_on_splash_end)
	$Timer.start()
	
func _on_splash_end():
	get_tree().change_scene_to_packed(menu_scene)
