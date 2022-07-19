extends CanvasLayer


func _ready():
	Global.game_ui = self
	$CenterContainer.visible = false


func show_respawn_button():
	$CenterContainer.visible = true
	
func _on_Button_pressed():
	#Network.instance_player(get_tree().get_network_unique_id(), Network.username)
	$CenterContainer.visible = false
	rpc("respawn_player", get_tree().get_network_unique_id(), Network.username)
	
func _exit_tree():
	Global.game_ui = null

sync func respawn_player(id, username : String):
	Network.instance_player(id, username)
