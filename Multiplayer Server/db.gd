extends Node

var players: Array[PackedStringArray]

func load_all():
	var file = FileAccess.open("user://database/players.csv", FileAccess.READ)
	while !file.eof_reached():
		players.append(file.get_csv_line())
