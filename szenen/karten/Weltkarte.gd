extends Control

func _ready() -> void:
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		print(item)
		if item.ends_with(".png"):
			var new_texture = TextureRect.new()
			new_texture.texture = load("res://karten/weltkarte/"+item)
			self.add_child(new_texture)
