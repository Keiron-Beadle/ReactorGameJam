extends Button

var reactor
signal clicked

func set_reactor(in_reactor):
	reactor = in_reactor
	text = in_reactor.name
	button_up.connect(_on_clicked)
	
func _on_clicked():
	clicked.emit(reactor)
