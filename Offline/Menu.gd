extends Control


onready var ip_input = $CenterContainer/VBoxContainer/IPInput
onready var server_button = $CenterContainer/VBoxContainer/ServerButton
onready var client_button = $CenterContainer/VBoxContainer/ClientButton
onready var warning_label = $CenterContainer2/Label
onready var username_input = $CenterContainer/VBoxContainer/UsernameInput


func _ready():
	warning_label.text = Network.ip_address
		
func _on_ServerButton_pressed():
	if !check_name_input():
		return
	Network.create_server()
	get_tree().change_scene("res://Online/Game.tscn")
	hide()
	
func _on_ClientButton_pressed():
	if len(ip_input.text) > 0:
		Network.ip_address = ip_input.text
	if !check_name_input():
		return
	Network.join_server()
	get_tree().change_scene("res://Online/Game.tscn")
	hide()
	
func check_name_input() -> bool:
	if len(username_input.text) > 0:
		Network.username = username_input.text
		return true
	else:
		warning_label.text = Network.ip_address + " : Warning: username has to be greater than 0 characters"
		return false
