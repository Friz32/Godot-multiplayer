extends Node

var players := {}

func load_all():
	var file = FileAccess.open("user://database/players.csv", FileAccess.READ)
	file.get_line() # Skip
	while !file.eof_reached():
		var csv = file.get_csv_line()
		if csv == PackedStringArray([""]):
			continue
		
		players[csv[0]] = {
			"username": csv[1],
			"password": csv[2],
			"display_name": csv[3],
			"scene": csv[4],
			"position": Vector3(float(csv[5]), float(csv[6]), float(csv[7])),
		}

func save_all():
	var file = FileAccess.open("user://database/players.csv", FileAccess.WRITE)
	file.store_line("UUID,Username,Password,Display name,Scene,Position X,Position Y,Position Z")
	for uuid in players.keys():
		var data = players[uuid]
		file.store_csv_line([
			uuid,
			data["username"],
			data["password"],
			data["display_name"],
			data["scene"],
			data["position"].x,
			data["position"].y,
			data["position"].z,
		])
