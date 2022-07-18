extends Node2D


#laser attributes:
#- damage tick speed
#- fall off damage?
#- charge and retreat rate (how long time takes to charge)
export var laser_damage : int = 4
export var damage_tick_speed : float = 0.2
export var charge_and_retreat_speed : float = 0.5
export var laser_distance : int = 2000

var laser_dir : Vector2 = Vector2()
var active : bool = false
var time_since_last_tick : float = 0.0
var can_damage : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$RayCast2D.enabled = active
	$RayCast2D.cast_to = Vector2(laser_distance, 0)
	$RayCast2D.add_exception(get_parent())
	
func _process(delta):
	$RayCast2D.cast_to = laser_dir.normalized() * laser_distance
	if can_damage:
		time_since_last_tick += delta
	else:
		time_since_last_tick = 0.0
	if time_since_last_tick >= damage_tick_speed:
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			if collider.is_in_group('entity'):
				collider.damage(laser_damage)
		time_since_last_tick = 0.0
		
func start():
	$Timer.start(charge_and_retreat_speed)
	
func end():
	$Timer.start(charge_and_retreat_speed)
	
func toggle_active():
	$Timer.stop()
	active = !active 
	$Timer.start(charge_and_retreat_speed)

func _on_Timer_timeout():
	$RayCast2D.enabled = active
	can_damage = active
