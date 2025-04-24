extends Control 

var bars = []

func _ready():
	var rect_size = get_rect().size
	var height = rect_size.y
	for x in range(int(height / 14)):
		var tex_rec = TextureRect.new()
		tex_rec.set_anchors_preset(Control.PRESET_CENTER)
		bars.append(tex_rec)
		$VBoxContainer.add_child(tex_rec)
	
func set_progress(percent):
	var pct_split = 100.0 / len(bars)
	var running_pct = 0.0
	for i in range(len(bars)):
		running_pct += pct_split
		if running_pct < percent:
			bars[len(bars)-1-i].modulate = Color.WHITE
		else:
			bars[len(bars)-1-i].modulate = Color.DIM_GRAY
	
func set_texture(texture):
	for bar in bars:
		bar.set_texture(texture)
