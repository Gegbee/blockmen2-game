extends Node

var player_master : Entity2D = null
var game_ui : CanvasLayer = null

func instance_node_at_location(node: Object, parent: Object, location: Vector2):
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance
	
func instance_node(node: Object, parent: Object):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

