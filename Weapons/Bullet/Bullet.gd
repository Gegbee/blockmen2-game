extends KinematicBody2D

var direction = Vector2()
var speed := 400
var damage := 20

var velocity : Vector2 = Vector2()

puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0

var initial_position := Vector2()

var player_owner : int = 0

signal in_init_position()

func _ready():
	visible = false
	z_index = 10
	yield(get_tree(), "idle_frame")
	
	if is_network_master():
		velocity = direction * speed
		rotation = atan2(direction.y, direction.x) + PI/2
		rset("puppet_velocity", velocity)
		rset("puppet_rotation", rotation)
		rset("puppet_position", global_position)
	visible = true
	connect("in_init_position", $Trail, "bullet_in_init_position")
	emit_signal("in_init_position")
	
func _physics_process(delta):
	if is_network_master():
		var _movement = move_and_slide(velocity)
	else:
		rotation = puppet_rotation
		var _movement = move_and_slide(puppet_velocity)
		
	if get_tree().is_network_server():
		if get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision.collider.is_in_group("entity"):
				collision.collider.damage(damage)
			rpc("destroy")
		if (global_position - initial_position).length() > 2000:
			rpc("destroy")
			
func puppet_position_set(new_value):
	puppet_position = new_value
	global_position = puppet_position
	
remotesync func destroy():
	queue_free()
