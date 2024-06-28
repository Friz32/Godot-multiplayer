class_name Warp3D
extends Area3D

@export_file("*.tscn", "*.scn", "*.res") var scene := ""
@export var player_position: Vector3
@export var player_rotation: Vector3

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D):
	if !body.is_in_group("player"):
		return
	
	if scene != null:
		get_tree().change_scene_to_file(scene)
	
	body.position = player_position
	body.camera.rotation = player_rotation
	
	MP.send_player_scene.rpc_id(1, scene)
	MP.send_player_transform.rpc_id(1, player_position, player_rotation)
