extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var main_tab: Control = $TabContainer/Main
@onready var multiplayer_tab: Control = $TabContainer/Multiplayer
@onready var failed_to_connect_tab: Control = $TabContainer/FailedToConnect
@onready var connect_tab: Control = $TabContainer/Connect
@onready var ip: LineEdit = %IP
@onready var port: LineEdit = %Port
@onready var login: LineEdit = %Login
@onready var password: LineEdit = %Password

func _ready() -> void:
	tab_container.current_tab = 0
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)

func connect_to_server(ip: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func on_connected_to_server():
	Networking.connect_to_server.rpc_id(1, login.text, password.text)

func on_connection_failed():
	tab_container.current_tab = tab_container.get_tab_idx_from_control(failed_to_connect_tab)

func on_multiplayer_pressed() -> void:
	tab_container.current_tab = tab_container.get_tab_idx_from_control(multiplayer_tab)

func on_connect_tab_pressed() -> void:
	tab_container.current_tab = tab_container.get_tab_idx_from_control(connect_tab)

func on_connect_cancel_pressed() -> void:
	tab_container.current_tab = tab_container.get_tab_idx_from_control(multiplayer_tab)

func on_multiplayer_cancel_pressed() -> void:
	tab_container.current_tab = tab_container.get_tab_idx_from_control(main_tab)

func on_failed_to_connect_back_pressed() -> void:
	tab_container.current_tab = tab_container.get_tab_idx_from_control(multiplayer_tab)

func on_connect_pressed() -> void:
	connect_to_server(ip.text, int(port.text))

func on_local_host_pressed() -> void:
	connect_to_server("127.0.0.1", 8888)
