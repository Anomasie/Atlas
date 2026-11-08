class_name KlickKarte
extends Karte

signal country_selected

var guess : String = ""

func _ready() -> void:
	AllSprites = $AllSprites
	RegionSprites = $RegionSprites
	Cam = $Cam
#	print(RegionSprites.get_children())

func load_data() -> void:
#	await load_countries()
	load_regions()

func _on_button_pressed() -> void:
	print("Klickkarte: get country please")
	var clicked_country : String = get_country(get_global_mouse_position(), guess)
	print("Klickkarte: got country thanks")
	if clicked_country:
		country_selected.emit(clicked_country)
