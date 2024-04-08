extends Node

var players := {}

func _ready() -> void:
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

@rpc("any_peer")
func connect_to_server(username: String, password: String):
	for uuid in DB.players.keys():
		var player = DB.players[uuid]
		if player["username"] == username && player["password"] == password:
			players[multiplayer.get_remote_sender_id()] = uuid
			go_to_scene.rpc_id(multiplayer.get_remote_sender_id(), player["scene"])

@rpc("any_peer")
func request_create_player(path: String):
	var peer_uuid = players[multiplayer.get_remote_sender_id()]
	for uuid in DB.players.keys():
		var player = DB.players[uuid]
		if uuid == peer_uuid && "res://scenes/world/" + player["scene"] + ".tscn" == path:
			create_player.rpc_id(multiplayer.get_remote_sender_id(), player["position"])

@rpc("any_peer")
func send_player_position(position: Vector3):
	var uuid = players[multiplayer.get_remote_sender_id()]
	DB.players[uuid]["position"] = position

@rpc("any_peer")
func send_player_scene(scene: String):
	var uuid = players[multiplayer.get_remote_sender_id()]
	var path = scene.trim_prefix("res://scenes/world").get_basename()
	DB.players[uuid]["scene"] = path

@rpc func go_to_scene(path: String): pass
@rpc func create_player(position: Vector3): pass

func on_peer_disconnected(id: int):
	players.erase(id)
