extends CanvasLayer


func _input(event):
	if is_network_master() and Input.is_action_pressed("reset_server"):
		Network.reset_game()
		print("server would be reset right now")
