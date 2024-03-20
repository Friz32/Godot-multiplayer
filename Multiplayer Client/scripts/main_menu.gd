extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var main_tab: Control = $TabContainer/Main
@onready var multiplayer_tab: Control = $TabContainer/Multiplayer
@onready var failed_to_connect_tab: Control = $TabContainer/FailedToConnect
@onready var connect_tab: Control = $TabContainer/Connect
@onready var ip: LineEdit = %IP
@onready var port: LineEdit = %Port
@onready var le_login: LineEdit = %Login
@onready var le_password: LineEdit = %Password

var login := ""
var password := ""

func _ready() -> void:
	tab_container.current_tab = 0
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)

func connect_to_server(ip: String, port: int, login: String, password: String):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
	self.login = login
	self.password = password

func on_connected_to_server():
	Networking.connect_to_server.rpc_id(1, login, password)

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
	connect_to_server(ip.text, int(port.text), le_login.text, le_password.text)

func on_local_host_pressed() -> void:
	connect_to_server("127.0.0.1", 8888, "admin", "123456")
