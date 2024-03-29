extends Node2D

var blaster = null

func _ready():
	z_index = 12
	
func _process(_delta):
	if !get_parent().is_network_master():
		return
	blaster = get_parent().cur_weapon
	global_position = get_global_mouse_position()
	update()
	
func _draw():
	if !get_parent().is_network_master():
		return
	if blaster and blaster.is_in_group('gun'):
		var center = Vector2.ZERO
		var accuracy = blaster.current_accuracy * PI / 100
		var absolute_vector = (blaster.global_position - global_position).length()
		var accuracy_vector = (Vector2(cos(blaster.rotation + accuracy), sin(blaster.rotation + accuracy)) * absolute_vector).length()
		var radius = sqrt(
			pow(accuracy_vector, 2)
			+ pow(absolute_vector, 2)
			- 2 * accuracy_vector * absolute_vector * cos(accuracy)
			)
		var color = Color(1.0, 1.0, 1.0, 0.5)
		draw_circle_arc(center, radius, 0, 360, color)
	else:
		var center = Vector2.ZERO
		var radius = 10
		var color = Color(1.0, 1.0, 1.0, 0.5)
		draw_circle_arc(center, radius, 0, 1000, color)
		
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)
