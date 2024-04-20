extends Node3D

var uuid := ""

func _process(delta: float) -> void:
	if !MP.other_players.has(uuid) || MP.other_players[uuid]["scene"] != get_tree().current_scene.scene_file_path.trim_prefix("res://scenes/world/").get_basename():
		queue_free()
		return
	
	position = MP.other_players[uuid]["position"]
