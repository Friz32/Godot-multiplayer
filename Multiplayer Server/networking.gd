extends Node

var players := {}

@rpc("any_peer")
func connect_to_server(username: String, password: String):
	for i in range(1, DB.players.size()):
		if DB.players[i][1] == username && DB.players[i][2] == password:
			players[multiplayer.get_remote_sender_id()] = DB.players[i][0]
			go_to_scene.rpc_id(multiplayer.get_remote_sender_id(), DB.players[i][4])

@rpc func go_to_scene(path: String): pass
