extends Control

@onready var Rect : Sprite2D = $Rect
@onready var Country : TextureRect = $Country
@onready var MyLabel : Label = $Label

func _ready() -> void:
	load_random_country()

func load_random_country() -> void:
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names : Array = dir.get_files()
	var file = file_names.pick_random()
	while not file.ends_with(".png"):
		file = file_names.pick_random()
	var array = file.split("-")
	var country_name : String = ""
	
	if len(array) <= 1:
		print("array of ", file, " too short")
		return
	
	# load karte
	country_name = array[1]
	Country.set_texture( load("res://karten/weltkarte/"+file) )
	MyLabel.text = country_name
	
	if not country_name in Global.countries.keys():
		print("country ", country_name, " not in Global.countries")
		return
	
	# load rect
	var rect : Rect2i = Global.countries[country_name]["Rect"]
	Rect.position = rect.position
	Rect.scale = Vector2(rect.size)


func _on_reload_pressed() -> void:
	load_random_country()
