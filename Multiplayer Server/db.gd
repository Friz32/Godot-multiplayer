extends Node

var players := {}

func load_all():
	var file = FileAccess.open("user://database/players.csv", FileAccess.READ)
	while !file.eof_reached():
		var csv = file.get_csv_line()
		players[csv[0]] = {
			"username": csv[1],
			"password": csv[2],
			"display_name": csv[3],
			"scene": csv[4],
			"position": Vector3(float(csv[5]), float(csv[6]), float(csv[7])),
		}
