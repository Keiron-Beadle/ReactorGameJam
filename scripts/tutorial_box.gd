extends Control

signal next_tutorial
signal tutorial_cancelled

@onready var msg = $TextureRect/Message

func _ready():
	$TextureRect/Button.button_up.connect(_emit_next_tutorial)
	get_node("TextureRect/Quit").button_up.connect(_quit)

func _emit_next_tutorial():
	next_tutorial.emit()
	visible = false

func _quit():
	tutorial_cancelled.emit()
	queue_free()

func set_text(text):
	msg.text = text
