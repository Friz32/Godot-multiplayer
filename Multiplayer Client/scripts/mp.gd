extends Node

@onready var info: Control = $CanvasLayer/Info
@onready var title_label: Label = %Title
@onready var message_label: Label = %Message

var previous_scene
var other_players := {}

func _ready() -> void:
	info.visible = false
	
	multiplayer.server_disconnected.connect(on_server_disconnected)

func _process(delta: float) -> void:
	if previous_scene != get_tree().current_scene && get_tree().current_scene != null && !multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		request_create_player.rpc_id(1, get_tree().current_scene.scene_file_path)
		request_other_players.rpc_id(1, get_tree().current_scene.scene_file_path)
	previous_scene = get_tree().current_scene

func show_info(title: String, message := ""):
	title_label.text = title
	message_label.text = message
	info.show()

@rpc func go_to_scene(path: String):
	get_tree().change_scene_to_file("res://scenes/world/" + path + ".tscn")

@rpc func create_player(position: Vector3, rotation: Vector3):
	var player = preload("uid://ddytpwtic2g2r").instantiate()
	player.position = position
	player.get_node("%Camera").rotation = rotation
	get_tree().current_scene.add_child(player)

@rpc func create_other_players(other_players: Dictionary):
	for uuid in other_players.keys():
		var other_player = preload("uid://qn8iye62tqws").instantiate()
		other_player.uuid = uuid
		other_player.position = other_players[uuid]["position"]
		other_player.get_node("Model").rotation.y = other_players[uuid]["rotation"]
		other_player.get_node("Name").text = other_players[uuid]["display_name"]
		get_tree().current_scene.add_child(other_player)

@rpc func create_other_player(uuid: StringName, position: Vector3, display_name: String):
	var other_player = preload("uid://qn8iye62tqws").instantiate()
	other_player.uuid = uuid
	other_player.position = position
	other_player.get_node("Name").text = display_name
	get_tree().current_scene.add_child(other_player)

@rpc func send_other_players(other_players: Dictionary):
	self.other_players = other_players

@rpc("any_peer") func connect_to_server(username: String, password: String): pass
@rpc("any_peer") func request_create_player(path: String): pass
@rpc("any_peer") func request_other_players(path: String): pass
@rpc("any_peer") func send_player_transform(position: Vector3, rotation: Vector3): pass
@rpc("any_peer") func send_player_scene(scene: String): pass

func on_server_disconnected():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file("uid://di83yg33a8u6")

func on_ok_pressed() -> void:
	info.hide()
