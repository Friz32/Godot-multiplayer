extends Node

var previous_scene

func _process(delta: float) -> void:
	if previous_scene != get_tree().current_scene && get_tree().current_scene != null && !multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		request_create_player.rpc_id(1, get_tree().current_scene.scene_file_path)
	previous_scene = get_tree().current_scene

@rpc
func go_to_scene(path: String):
	get_tree().change_scene_to_file("res://scenes/world/" + path + ".tscn")

@rpc
func create_player(position: Vector3):
	var player = preload("uid://ddytpwtic2g2r").instantiate()
	get_tree().current_scene.add_child(player)

@rpc("any_peer") func connect_to_server(username: String, password: String): pass
@rpc("any_peer") func request_create_player(path: String): pass
@rpc("any_peer") func send_player_position(position: Vector3): pass
@rpc("any_peer") func send_player_scene(scene: String): pass
