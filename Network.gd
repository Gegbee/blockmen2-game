extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 12

var server : NetworkedMultiplayerENet = null
var client : NetworkedMultiplayerENet = null

var username = ""
var ip_address = ""

const PLAYER = preload("res://Player/Player.tscn")
const RESET_POWER = preload("res://Menu/ResetPower.tscn")

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

func _ready():
#	if OS.get_name() == "Windows":
#		ip_address = IP.get_local_addresses()[3]
#
#	for address in IP.get_local_addresses():
#		if address.begins_with("192.168.") and not address.ends_with(".1"):
#			ip_address = address
#			break
	
	ip_address = "localhost"
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")

func _network_peer_connected(id):
	print("peer connected")
	# INSTANCE PUPPET PLAYERS
	#instance_player(id)
	rpc_id(id, "instance_player", get_tree().get_network_unique_id(), username)
	
func _network_peer_disconnected(id):
	print("peer disconnected")
	if Objects.has_node(str(id)):
		Objects.get_node(str(id)).queue_free()
		
func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	print("server created")
	instance_player(get_tree().get_network_unique_id(), username)
	var reset_power = Global.instance_node(RESET_POWER, Objects)
	# INSTANCE SERVER'S PLAYER
	reset_power.set_network_master(get_tree().get_network_unique_id())
	
func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	print("client created")
	
func _connected_to_server():
	print("connected")
	yield(get_tree().create_timer(0.1), "timeout")
	# INSTANCE NEW CLIENT'S PLAYER
	instance_player(get_tree().get_network_unique_id(), username)
	
func _server_disconnected():
	print("disconnected")
	get_tree().set_network_peer(null)
	client.disconnect_peer(get_tree().get_network_unique_id())
	get_tree().change_scene("res://Offline/Menu.tscn")

remote func instance_player(id, _username) -> void:
	var player_instance = PLAYER.instance()
	player_instance.name = str(id)
	player_instance.puppet_username = _username
	player_instance.set_network_master(id)
	Objects.add_child(player_instance)
	
func reset_game():
	pass
	
func start_game():
	pass

func networked_object_name_index_set(new_val):
	networked_object_name_index = new_val
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
		
func puppet_networked_object_name_index_set(new_val):
	networked_object_name_index = new_val
