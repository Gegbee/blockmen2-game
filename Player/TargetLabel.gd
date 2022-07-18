extends Label


var offset : Vector2 = Vector2()
var target := Vector2()

func _ready():
	rect_size = Vector2(132, 14)
	
func _process(delta):
	rect_position = target + offset
