extends Control

@onready var plot = $Line2D
@onready var label = $Label

var minimum = 0
var maximum = 0
var points = []

func set_points(data):
	points = data
	minimum = 0
	maximum = data[0] if data[0] > 0 else 1
	for x in data:
		if x < minimum:
			minimum = x
		if x > maximum:
			maximum = x
	draw()

func set_label(text):
	label.text = text

func draw():
	plot.clear_points()
	var rect_size = get_rect().size
	var control_width = rect_size.x  # Get the width of the Control node
	var control_height = rect_size.y # Get the height (if needed)
	
	var num_points = points.size()
	if num_points == 0:
		return  # Prevent division by zero

	for i in range(num_points):
		var x = (i / float(num_points - 1)) * control_width  # Distribute X evenly
		var y = control_height - (points[i] / maximum) * control_height  # Scale Y
		
		plot.add_point(Vector2(x, y))
