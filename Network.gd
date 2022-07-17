extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") and not address.ends_with(".1"):
			ip_address = address
			break
			
	print(IP.get_local_addresses())
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	print("server created")
	
func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	print("client created")
	
func _connected_to_server():
	print("connected")
	
func _server_disconnected():
	print("disconnected")
	
