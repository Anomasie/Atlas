extends Control

const GRID = 3

@onready var WarteLabel = $PanelContainer/WarteLabel

func _ready() -> void:
	WarteLabel.text = "Lade Länder!"
	await load_ländergrößen()
	WarteLabel.text = "Fertig!"

func find_some_pixel(image : Image) -> Vector2i:
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x,y).a > 0:
				return Vector2i(x,y)
	return Vector2i.ZERO

func get_ländergrößen(country_list: Array) -> String :
	var dict : Dictionary[String, Vector2i] = {}
	
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	var last_country : String = ""
	var counter : int = 0
	
	for item in file_names:
		counter += 1
		if len(item.split("-")) > 1:
			var item_name : String = item.split("-")[1]
			if item.ends_with(".png"):
				if not item_name in country_list:
					print("ERROR in get_ländergrößen: ", item_name, " not in country_list")
				else:
					var image : Image = Image.load_from_file("res://karten/weltkarte/"+item)
					dict[item_name] = find_some_pixel(image)
					last_country = item_name
		if counter % 10 == 0:
			WarteLabel.text = "Lade " + last_country
			await get_tree().process_frame
	
	# convert into string
	WarteLabel.text = "Konvertiere in String"
	await get_tree().process_frame
	var dictstring : String = ""
	for key in dict.keys():
		dictstring += key + ";" + str(dict[key].x) + ";" + str(dict[key].y) + "\n"
	
	return dictstring

func load_ländergrößen() -> void:
	# make dictionary
	var country_dict = Global.countries
	var dictstring : String = await get_ländergrößen(country_dict.keys())
	# save dictionary
	var file = FileAccess.open("res://karten/Ländergrößen.csv", FileAccess.WRITE)
	file.store_string(dictstring)
