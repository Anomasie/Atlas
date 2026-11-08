extends Control

const GRID = 3

@onready var WarteLabel = $PanelContainer/WarteLabel

func _ready() -> void:
	WarteLabel.text = "Lade Länder!"
	await load_ländergrößen()
	await get_tree().process_frame
	get_tree().quit()

func find_first_x(image) -> Vector2i:
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x,y).a > 0:
				return Vector2i(x,y)
	return Vector2i.ZERO

func find_first_y(image, start_x, end_y) -> int:
	for y in range(0, end_y+10):
		for x in range(start_x, image.get_width()):
			if image.get_pixel(x,y).a > 0:
				return y
	return 0

func find_start(image : Image) -> Vector2i:
	var start_x = find_first_x(image)
	return Vector2i(start_x.x, find_first_y(image, start_x.x, start_x.y))

func find_last_x(image : Image, start : Vector2i) -> Vector2i:
	var x_range = range(start.x, image.get_width())
	x_range.reverse()
	for x in x_range:
		for y in range(start.y, image.get_height()):
			if image.get_pixel(x,y).a > 0:
				return Vector2i(x+1, y)
	return Vector2i(image.get_width(), image.get_height())

func find_last_y(image : Image, start : Vector2i, end_x: int) -> int:
	var y_range = range(start.y, image.get_height())
	y_range.reverse()
	for y in y_range:
		for x in range(start.x, end_x):
			if image.get_pixel(x,y).a > 0:
				return y+1
	return y_range[0]

func find_end(image : Image, start : Vector2i) -> Vector2i:
	var end_x : Vector2i = find_last_x(image, start)
	return Vector2i(end_x.x, find_last_y(image, start, end_x.x))

func find_rect(image : Image) -> Rect2i:
	var start : Vector2i = find_start(image)
	return Rect2i(start, find_end(image, start) - start)

func get_ländergrößen(country_list: Array) -> String :
	var dict : Dictionary[String, Rect2i] = {}
	
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
					dict[item_name] = find_rect(image)
					last_country = item_name
		if counter % 10 == 0:
			WarteLabel.text = "Lade " + last_country
			await get_tree().process_frame
	
	# convert into string
	WarteLabel.text = "Konvertiere in String"
	await get_tree().process_frame
	var dictstring : String = ""
	for key in dict.keys():
		var rect_str : Array = [dict[key].position.x, dict[key].position.y, dict[key].size.x, dict[key].size.y]
		dictstring += key + ";" + ",".join(rect_str) + "\n"
	
	return dictstring

func load_ländergrößen() -> void:
	# make dictionary
	var country_dict = Global.countries
	var dictstring : String = await get_ländergrößen(country_dict.keys())
	# save dictionary
	print(dictstring)
	var file = FileAccess.open("res://karten/Ländergrößen.csv", FileAccess.WRITE)
	await file.store_string(dictstring)
