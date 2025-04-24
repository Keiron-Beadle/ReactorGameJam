extends Control

@onready var difficulty_button = $VBoxContainer/Control/Button
@onready var day_length_button = $VBoxContainer/Control3/Button
@onready var language_button = $VBoxContainer/Control2/Button
@onready var email_dialogue_button = $VBoxContainer/Control4/Button
@onready var back_button = $VBoxContainer/BackButton
@onready var button_click_player = $ButtonClickAudio

func _ready():
	difficulty_button.button_up.connect(_on_change_difficulty)
	language_button.button_up.connect(_on_change_language)
	day_length_button.button_up.connect(_on_change_day_length)
	email_dialogue_button.button_up.connect(_on_change_email_dialogue)
	back_button.button_up.connect(_back_to_menu)
	
	difficulty_button.text = "[ %s ]" % GameData.difficulty
	language_button.text = "[ %s ]" % GameData.language
	day_length_button.text = "[ %s ]" % GameData.day_length
	
func _on_change_email_dialogue():
	button_click_player.play()
	GameData.email_dialogue = 'On' if GameData.email_dialogue == 'Off' else 'Off'
	email_dialogue_button.text = "[ %s ]" % GameData.email_dialogue
		
func _on_change_difficulty():
	button_click_player.play()
	GameData.difficulty = 'Normal' if GameData.difficulty == 'Easy' else 'Easy'
	difficulty_button.text = "[ %s ]" % GameData.difficulty

func _on_change_language():
	button_click_player.play()
	if GameData.language == 'English':
		#GameData.language = 'Espanol'
		GameData.language = 'Deutsch'
	elif GameData.language == 'Espanol':
		GameData.language = 'Deutsch'
	else:
		GameData.language = 'English'
	language_button.text = "[ %s ]" % GameData.language
	
func _on_change_day_length():
	button_click_player.play()
	if GameData.day_length == '1 Min':
		GameData.day_length = '2 Min'
	elif GameData.day_length == '2 Min':
		GameData.day_length = '3 Min'
	elif GameData.day_length == '3 Min':
		GameData.day_length = '4 Min'
	else:
		GameData.day_length = '1 Min'
	day_length_button.text = "[ %s ]" % GameData.day_length

func _back_to_menu():
	button_click_player.play()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
