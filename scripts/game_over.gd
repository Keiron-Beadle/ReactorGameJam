extends Control

@onready var result_label : Label = $Label
@onready var audio_player = $AudioPlayer
@onready var fade1 = $FadeBackground1
@onready var fade2 = $FadeBackground2

func _ready():
	if GameData.game_result != 'Won':
		result_label.text = GameData.game_result
		result_label.add_theme_color_override("font_color", Color('#f55856'))
		
	if 'Meltdown' in GameData.game_result:
		audio_player.stream = load("res://assets/explosion.mp3")
		audio_player.volume_db = -15
	
	audio_player.play()
	$QuitButton.button_up.connect(_on_quit)
	
	await get_tree().create_timer(1.0).timeout
	
	var tween = create_tween()
	var end_color = fade1.color
	end_color.a = 0.0
	tween.tween_property(fade1, 'modulate', end_color, 2)
	tween.tween_property(fade2, 'modulate', end_color, 2)
	tween.tween_callback(_on_tween_finished)
	
func _on_tween_finished():
	fade1.visible = false
	fade2.visible = false
	
func _on_quit():
	get_tree().quit()
