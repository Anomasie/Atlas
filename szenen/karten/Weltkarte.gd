extends Control

signal country_selected

var highligted_countries : Array = []

func _ready() -> void:
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if item.ends_with(".png"):
			var new_texture = TextureRect.new()
			new_texture.set_texture( load("res://karten/weltkarte/"+item) )
			new_texture.set_name(item.split("-")[1])
			new_texture.self_modulate = Color.BLACK
			self.add_child(new_texture)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var clicked_country : String = get_country(get_global_mouse_position())
		$Label.set_text( clicked_country )
		highlight([clicked_country])
		country_selected.emit(clicked_country)

func get_country(koordinaten: Vector2) -> String:
	for kid in self.get_children():
		if kid is TextureRect:
			var color = kid.get_texture().get_image().get_pixel(koordinaten.x, koordinaten.y)
			if color == Color.WHITE:
				return kid.name
	return "No country there"

func highlight(list_of_countries=[]) -> void:
	# anti-highlight all
	for country in highligted_countries:
		if self.get_node(country):
			self.get_node(country).self_modulate = Color.BLACK
	highligted_countries = list_of_countries
	for country in highligted_countries:
		if self.get_node(country):
			self.get_node(country).self_modulate = Color.WHITE
