extends Control

@onready var port: LineEdit = %Port
@onready var max_clients: LineEdit = %MaxClients
@onready var start_server: Button = %StartServer
@onready var output: RichTextLabel = %Output
@onready var tab_container: TabContainer = $TabContainer

var server_enabled := false

func _ready() -> void:
	tab_container.current_tab = 0
	
	multiplayer.peer_connected.connect(on_peer_connected)

func on_start_server_pressed() -> void:
	if !server_enabled:
		DB.load_all()
		
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(int(port.text), int(max_clients.text))
		multiplayer.multiplayer_peer = peer
		
		start_server.text = "Stop Server"
		start_server.modulate = Color(0.8, 0.3, 0.3)
		server_enabled = true
		
		output.add_text("\nServer started")
	else:
		multiplayer.multiplayer_peer = null
		
		start_server.text = "Start Server"
		start_server.modulate = Color.WHITE
		server_enabled = false
		
		output.add_text("\nServer stopped")

func on_peer_connected(id: int):
	output.add_text(str("\nPeer ", id, " connected"))
