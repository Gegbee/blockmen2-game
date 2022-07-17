extends KinematicBody2D

const SPEED = 100
var velocity := Vector2()

var username : String = "default"

puppet var puppet_username : String = "default"

onready var tween = $Tween

puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0
const TICK_RATE : float = 0.03
var time : float = 0.0

	
func _process(delta : float):
	
	time += delta
	if is_network_master():
		$Label.text = username
		var input = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		velocity = input.normalized()
		move_and_slide(velocity * SPEED)

		look_at(get_global_mouse_position())
		if time >= TICK_RATE:
			rset("puppet_username", username)
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_rotation", rotation_degrees)
			rset_unreliable("puppet_velocity", velocity)
			time = 0.0
	else:
		$Label.text = puppet_username
		rotation_degrees = rad2deg(lerp_angle(deg2rad(rotation_degrees), deg2rad(puppet_rotation), delta * 8))
		
		if not tween.is_active():
			move_and_slide(velocity * SPEED)
		
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()
	
func _on_Timer_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation_degrees)
		rset_unreliable("puppet_velocity", velocity)
