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
			"rotation": Vector2(deg_to_rad(float(csv[8])), deg_to_rad(float(csv[9]))),
		}

func save_all():
	var file = FileAccess.open("user://database/players.csv", FileAccess.WRITE)
	file.store_line("UUID,Username,Password,Display name,Scene,Position X,Position Y,Position Z,Rotation X,Rotation Y")
	for uuid in players.keys():
		var data = players[uuid]
		file.store_csv_line([
			uuid,
			data["username"],
			data["password"],
			data["display_name"],
			data["scene"],
			"%.3f" % data["position"].x,
			"%.3f" % data["position"].y,
			"%.3f" % data["position"].z,
			round(rad_to_deg(data["rotation"].x)),
			round(rad_to_deg(data["rotation"].y)),
		])
