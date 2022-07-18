extends Entity2D

const SPEED = 100
var velocity := Vector2()

var puppet_username : String = "default"

onready var tween = $Tween

puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0
const TICK_RATE : float = 0.03
var time : float = 0.0

#const USERNAME_LABEL = preload("res://Player/TargetLabel.tscn")
#var username_label = null

var cur_weapon = null

func _ready():
	add_to_group('player')
	cur_weapon = $Gun
	#username_label = Global.instance_node(USERNAME_LABEL, Objects)
	#username_label.offset = Vector2(-66, -36)
	if is_network_master():
		Global.player_master = self
		activate_camera()

func activate_camera():
	$Camera2D.current = true
	
func _process(delta : float):
	time += delta
	#username_label.target = global_position
	if is_network_master():
		$Username/Label.text = Network.username
		var input = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		velocity = input.normalized()
		move(velocity * SPEED)

		look_at(get_global_mouse_position())
		if time >= TICK_RATE:
			#rset("puppet_username", Network.username)
			#puppet.transform
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_rotation", rotation_degrees)
			rset_unreliable("puppet_velocity", velocity)
			time = 0.0
			
		if cur_weapon:
			if cur_weapon.is_in_group('gun'):
				cur_weapon.shoot_dir = Vector2(cos(rotation), sin(rotation))
				if cur_weapon.automatic:
					if Input.is_action_pressed("attack"):
						cur_weapon.rpc("attack", int(name), rotation)
				else:
					if Input.is_action_just_pressed("attack"):
						cur_weapon.rpc("attack", int(name), rotation)
				if Input.is_action_just_pressed("reload"):
					cur_weapon.rpc("reload")
	else:
		$Username/Label.text = puppet_username
		rotation_degrees = rad2deg(lerp_angle(deg2rad(rotation_degrees), deg2rad(puppet_rotation), delta * 8))
		
		if not tween.is_active():
			move(velocity * SPEED)
			
	$Username.global_rotation = 0
	
	#player reports when they dide to other clients
		
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()
	
#func _on_Timer_timeout():
#	if is_network_master():
#		rset_unreliable("puppet_position", global_position)
#		rset_unreliable("puppet_rotation", rotation_degrees)
#		rset_unreliable("puppet_velocity", velocity)

func _exit_tree():
	if is_network_master():
		Global.player_master = null
		
