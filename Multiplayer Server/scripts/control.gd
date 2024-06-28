extends Control

@onready var port: LineEdit = %Port
@onready var max_clients: LineEdit = %MaxClients
@onready var start_server: Button = %StartServer
@onready var output: RichTextLabel = %Output
@onready var tab_container: TabContainer = $TabContainer
@onready var autostart: CheckBox = %Autostart

@onready var peer_count: Label = %PeerCount

var server_enabled := false

func _ready() -> void:
	tab_container.current_tab = 0
	
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func _process(delta: float) -> void:
	peer_count.text = str(multiplayer.get_peers().size())

func on_start_server_pressed() -> void:
	if !server_enabled:
		start()
	else:
		stop()

func on_peer_connected(id: int):
	output.add_text(str("\nPeer ", id, " connected"))

func on_peer_disconnected(id: int):
	output.add_text(str("\nPeer ", id, " disconnected"))

func start():
	DB.load_all()
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(port.text), int(max_clients.text))
	multiplayer.multiplayer_peer = peer
	
	start_server.text = "Stop Server"
	start_server.modulate = Color(0.8, 0.3, 0.3)
	server_enabled = true
	
	output.add_text("\nServer started")

func stop():
	DB.save_all()
	MP.stop_server()
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	
	start_server.text = "Start Server"
	start_server.modulate = Color.WHITE
	server_enabled = false
	
	output.add_text("\nServer stopped")
