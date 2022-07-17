extends Control


const PLAYER = preload("res://Player/Player.tscn")

onready var ip_input = $CenterContainer/VBoxContainer/IPInput
onready var server_button  =$CenterContainer/VBoxContainer/ServerButton
onready var client_button = $CenterContainer/VBoxContainer/ClientButton
onready var warning_label = $CenterContainer2/Label
onready var username_input = $CenterContainer/VBoxContainer/UsernameInput


func _ready():
	get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")
	get_tree().connect("connected_to_server", self,"_connected_to_server")
	warning_label.text = Network.ip_address
	
func _network_peer_connected(id):
	print("peer connected")
	instance_player(id, username_input.text)
	
func _network_peer_disconnected(id):
	print("peer disconnected")
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()
		
func _on_ServerButton_pressed():
	if !check_name_input():
		return
	Network.create_server()
	hide()
	instance_player(get_tree().get_network_unique_id(), username_input.text)
	
func _on_ClientButton_pressed():
	if len(ip_input.text) > 0:
		Network.ip_address = ip_input.text
	if !check_name_input():
		return
	Network.join_server()
	hide()
	
func _connected_to_server():
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id(), username_input.text)
	
func instance_player(id, username) -> void:
	var player_instance = Global.instance_node_at_location(PLAYER, Players, Vector2())
	player_instance.name = str(id)
	if id == get_tree().get_network_unique_id():
		player_instance.username = username
	player_instance.set_network_master(id)

func check_name_input() -> bool:
	if len(username_input.text) > 0:
		return true
	else:
		warning_label.text = Network.ip_address + " : Warning: username has to be greater than 0 characters"
		return false
