extends Node

@rpc
func go_to_scene(path: String):
	get_tree().change_scene_to_file("res://scenes/world/" + path + ".tscn")

@rpc("any_peer") func connect_to_server(username: String, password: String): pass
