extends Node3D

@onready var model: Node3D = $Model

var uuid := ""

func _process(delta: float) -> void:
	if !MP.other_players.has(uuid) || MP.other_players[uuid]["scene"] != get_tree().current_scene.scene_file_path.trim_prefix("res://scenes/world/").get_basename():
		queue_free()
		return
	
	position = MP.other_players[uuid]["position"]
	model.rotation.y = MP.other_players[uuid]["rotation"]
	
