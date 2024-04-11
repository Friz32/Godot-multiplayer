extends Node

var players := {}

func _ready() -> void:
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func _process(delta: float) -> void:
	if !multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		var other_players = {}
		for uuid in players.values():
			other_players[uuid] = DB.players[uuid]["position"]
		
		send_other_players.rpc(other_players)

@rpc("any_peer")
func connect_to_server(username: String, password: String):
	for uuid in DB.players.keys():
		var player = DB.players[uuid]
		if player["username"] == username && player["password"] == password:
			players[multiplayer.get_remote_sender_id()] = uuid
			go_to_scene.rpc_id(multiplayer.get_remote_sender_id(), player["scene"])
			
			for peer in players:
				var u = players[peer]
				var p = DB.players[u]
				if u != uuid && p["scene"] == DB.players[uuid]["scene"]:
					create_other_player.rpc_id(peer, uuid, p["position"])

@rpc("any_peer")
func request_create_player(path: String):
	var peer_uuid = players[multiplayer.get_remote_sender_id()]
	for uuid in DB.players.keys():
		var player = DB.players[uuid]
		if uuid == peer_uuid && "res://scenes/world/" + player["scene"] + ".tscn" == path:
			create_player.rpc_id(multiplayer.get_remote_sender_id(), player["position"])

@rpc("any_peer")
func request_other_players(path: String):
	var other_players = {}
	for peer in players:
		if multiplayer.get_remote_sender_id() == peer:
			continue
		
		var uuid = players[peer]
		var player = DB.players[uuid]
		if "res://scenes/world/" + player["scene"] + ".tscn" == path:
			other_players[uuid] = player["position"]
	
	create_other_players.rpc_id(multiplayer.get_remote_sender_id(), other_players)

@rpc("any_peer")
func send_player_position(position: Vector3):
	var uuid = players[multiplayer.get_remote_sender_id()]
	DB.players[uuid]["position"] = position

@rpc("any_peer")
func send_player_scene(scene: String):
	var uuid = players[multiplayer.get_remote_sender_id()]
	var path = scene.trim_prefix("res://scenes/world/").get_basename()
	DB.players[uuid]["scene"] = path

@rpc func go_to_scene(path: String): pass
@rpc func create_player(position: Vector3): pass
@rpc func create_other_players(other_players: Dictionary): pass
@rpc func create_other_player(uuid: StringName, position: Vector3): pass
@rpc func send_other_players(other_players: Dictionary): pass

func on_peer_disconnected(id: int):
	players.erase(id)
