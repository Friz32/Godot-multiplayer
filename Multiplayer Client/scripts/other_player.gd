extends Node3D

var uuid := ""

func _process(delta: float) -> void:
	position = MP.other_players[uuid]
