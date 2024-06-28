extends Node

var players := {}

func _ready() -> void:
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func _process(delta: float) -> void:
	if !multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		var other_players = {}
		for uuid in players.values():
			var dict = {}
			dict["position"] = DB.players[uuid]["position"]
			dict["rotation"] = DB.players[uuid]["rotation"].y + PI
			dict["scene"] = DB.players[uuid]["scene"]
			other_players[uuid] = dict
		
		send_other_players.rpc(other_players)

func stop_server():
	players.clear()

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
					create_other_player.rpc_id(peer, uuid, p["position"], p["display_name"])

@rpc("any_peer")
func request_create_player(path: String):
	var peer_uuid = players[multiplayer.get_remote_sender_id()]
	for uuid in DB.players.keys():
		var player = DB.players[uuid]
		if uuid == peer_uuid && "res://scenes/world/" + player["scene"] + ".tscn" == path:
			create_player.rpc_id(multiplayer.get_remote_sender_id(), player["position"], Vector3(player["rotation"].x, player["rotation"].y, 0))

@rpc("any_peer")
func request_other_players(path: String):
	var other_players = {}
	for peer in players:
		if multiplayer.get_remote_sender_id() == peer:
			continue
		
		var uuid = players[peer]
		var player = DB.players[uuid]
		if "res://scenes/world/" + player["scene"] + ".tscn" == path:
			var dict = {}
			dict["position"] = player["position"]
			dict["rotation"] = player["rotation"].y + PI
			dict["display_name"] = player["display_name"]
			other_players[uuid] = dict
	
	create_other_players.rpc_id(multiplayer.get_remote_sender_id(), other_players)

@rpc("any_peer")
func send_player_transform(position: Vector3, rotation: Vector3):
	var uuid = players[multiplayer.get_remote_sender_id()]
	DB.players[uuid]["position"] = position
	DB.players[uuid]["rotation"] = Vector2(rotation.x, rotation.y)

@rpc("any_peer")
func send_player_scene(scene: String):
	var uuid = players[multiplayer.get_remote_sender_id()]
	var path = scene.trim_prefix("res://scenes/world/").get_basename()
	DB.players[uuid]["scene"] = path
	
	for peer in players:
		var player = DB.players[players[peer]]
		if peer != multiplayer.get_remote_sender_id() && player["scene"] == scene.trim_prefix("res://scenes/world/").get_basename():
			create_other_player.rpc_id(peer, uuid, DB.players[uuid]["position"], DB.players[uuid]["display_name"])

@rpc func go_to_scene(path: String): pass
@rpc func create_player(position: Vector3, rotation: Vector3): pass
@rpc func create_other_players(other_players: Dictionary): pass
@rpc func create_other_player(uuid: StringName, position: Vector3, display_name: String): pass
@rpc func send_other_players(other_players: Dictionary): pass

func on_peer_disconnected(id: int):
	players.erase(id)
