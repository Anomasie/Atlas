extends Karte

signal country_selected

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if item.ends_with(".png"):
			var new_texture = Sprite2D.new()
			new_texture.set_texture( load("res://karten/weltkarte/"+item) )
			new_texture.set_name(item.split("-")[1])
			new_texture.self_modulate = NORMAL_COLOR
			new_texture.material = self.material
			new_texture.centered = false
#			new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			AllSprites.add_child(new_texture)

func _on_button_pressed() -> void:
	var clicked_country : String = get_country(get_global_mouse_position())
	if clicked_country:
		country_selected.emit(clicked_country)
