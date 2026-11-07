extends Control

func _ready() -> void:
	print_all_mistakes()

func get_all_sprite_names() -> Array[String]:
	var result : Array[String] = []
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if len(item.split("-")) > 1:
			var item_name : String = item.split("-")[1]
			if item.ends_with(".png") and item_name:
				result.append(item_name)
	return result

func get_all_country_names() -> Array:
	return Global.countries.keys()

func print_all_mistakes() -> void:
	var sprite_name_list : Array[String] = get_all_sprite_names()
	var csv_name_list : Array = get_all_country_names()
	# sprite not in csv
	print()
	print("SPRITE NOT IN CSV:")
	for sprite in sprite_name_list:
		if sprite and not sprite in csv_name_list:
			print(sprite, " not in csv")
	print()
	# csv has no sprite
	print("CSV ENTRY HAS NO SPRITE:")
	for csv in csv_name_list:
		if csv and not csv in sprite_name_list:
			print(csv, " not in sprites")
	print()
	# wrong neighbors
	print("MISSING NEIGHBORS:")
	for csv in csv_name_list:
		for neighbor in Global.countries[csv]["Neighbors"]:
			if neighbor and csv:
				if not neighbor in csv_name_list:
					print(csv, " has neighbor ", neighbor, " which is not in csv")
				elif not csv in Global.countries[neighbor]["Neighbors"]:
					print(csv, " has neighbor ", neighbor, " but not vice versa")
