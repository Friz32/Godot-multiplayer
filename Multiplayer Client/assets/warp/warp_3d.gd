class_name Warp3D
extends Area3D

@export var scene: PackedScene
@export var destination: Vector3

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D):
	if scene != null:
		get_tree().change_scene_to_packed(scene)
	
	body.position = destination
	
	MP.send_player_scene.rpc_id(1, scene.resource_path)
