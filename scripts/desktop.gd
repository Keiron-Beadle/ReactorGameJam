extends Control

@export var mail_scene : PackedScene

var email_open : bool

@onready var email_notif_label = $Email/UnreadLabel

func _ready():
	if GameData.first_time_in_desktop:
		GameData.first_time_in_desktop = false
		$Email.visible = false
		$Reactor.visible = false
		$LoadIconsTimer.timeout.connect(_load_next_button)
		$LoadIconsTimer.start()
	$Email.button_up.connect(_on_email_open)
	$Reactor.button_up.connect(_on_game_start)
	
func _load_next_button():
	if not $Email.visible:
		$Email.visible = true
		return
	elif not $Reactor.visible:
		$Reactor.visible = true
		return
	
	$LoadIconsTimer.stop()

func _on_game_start():
	get_tree().change_scene_to_file("res://scenes/reactor.tscn")
	
func _on_email_open():
	if email_open:
		return

	email_notif_label.visible = false
	
	var mail_inst = mail_scene.instantiate()
	
	var email_text_arr = GameData.email_days
	if GameData.language == 'Espanol':
		email_text_arr = GameData.sp_email_days
	elif GameData.language == 'Deutsch':
		email_text_arr = GameData.de_email_days
	
	mail_inst.set_message(email_text_arr[GameData.day_ptr])
	
	if GameData.email_dialogue == 'On':
		var data_arr = GameData.email_voice
		if GameData.language == 'Espanol':
			data_arr = GameData.sp_email_voice
		elif GameData.language == 'Deutsch':
			data_arr = GameData.de_email_voice
		mail_inst.set_voice(data_arr[GameData.day_ptr])
	else:
		mail_inst.set_voice(null)
	
	add_child(mail_inst)
	
	mail_inst.tree_exited.connect(_on_mail_closed)
	email_open = true
	
func _on_mail_closed():
	email_open = false
