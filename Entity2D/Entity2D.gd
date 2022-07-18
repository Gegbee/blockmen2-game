extends KinematicBody2D

class_name Entity2D

export var health_bar_path : NodePath
var health_bar = null

export var MAX_HEALTH : int = 100
export var knockback_resistance : float = 1.0

var health : int = 100 setget set_health
puppet var puppet_health : int = 100 setget puppet_health_set
var impulse_vector : Vector2 = Vector2()
var impulse_strength : float = 0.0
var vel : Vector2 = Vector2()

var invincible : bool = false
puppet var puppet_invincible : bool = false setget puppet_invincible_set

var invincible_time : float = 0.0
puppet var puppet_invincible_time : float = 0.0

var timer := Timer.new()
var color_change_time := 0.0

signal OnEntityDead()

func _ready():
	#add_child(timer)
	#timer.one_shot = true
	#timer.connect("timeout", self, "timer_timeout")
	add_to_group('entity')
	if health_bar_path != null and health_bar_path != "":
		health_bar = get_node(health_bar_path)
	health = MAX_HEALTH
	if is_network_master():
		invincible = true
		invincible_time = 5.0
		rset("puppet_invincible", invincible)
		

func puppet_invincible_set(new_val):
	invincible = new_val

func health_set(new_val):
	health = new_val
	
	if is_network_master():
		rset("puppet_health", health)
	
func puppet_health_set(new_val):
	puppet_health = new_val
	
	if !is_network_master():
		health = puppet_health
	
func _process(delta):
	if is_network_master():
		rset("puppet_invincible", invincible)
		invincible_time -= delta
		if invincible_time <= 0.0:
			invincible_time = 0.0
			invincible = false
			rset("puppet_invincible", invincible)
#		rset_unreliable("puppet_invincible_time", invincible_time)
	else:
		#invincible_time = puppet_invincible_time
		pass
		
	if invincible:
		color_change_time += delta
		if color_change_time >= 0.3:
			color_change_time = 0.0
			if modulate == Color("5782ee"):
				modulate = "ffffff"
			else:
				modulate = "5782ee"
	else:
		color_change_time = 0.0
		modulate = "ffffff"

func _physics_process(delta):
	impulse_vector.x = lerp(impulse_vector.x, 0, 5.0 * delta)
	impulse_vector.y = lerp(impulse_vector.y, 0, 5.0 * delta)
	if impulse_vector.length() < 0.2:
		impulse_vector = Vector2()
		impulse_strength = 0.0
		
func move(move_vel : Vector2):
	vel = -impulse_vector + move_vel
	vel = move_and_slide(vel)
	return vel
	
sync func damage(dmg : int, impulse_dir : Vector2 = Vector2(), strength : float = 0):
	set_health(health - dmg)
	impulse(impulse_dir.normalized(), strength)
	print(self.name + " health: " + str(health) + " / " + str(MAX_HEALTH))

func set_health(new_health : int):
	if invincible:
		return
#	if new_health < health:
#		damage_color_change()
#	elif new_health > health:
#		healing_color_change()
	if new_health <= 0: #and health > 0:
		kys()
	health = new_health
	if health_bar:
		health_bar.updateHealth(health)
	
func kys():
	if is_network_master():
		print("DEAD AF")
		emit_signal("OnEntityDead")
		rpc("destroy")
	
func impulse(dir : Vector2, strength: float):
	impulse_strength = strength
	impulse_vector = dir * strength / knockback_resistance

sync func destroy():
	queue_free()
