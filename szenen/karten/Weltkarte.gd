extends Karte

signal country_selected

var guess : String = ""

func _ready() -> void:
	AllSprites = $AllSprites
	RegionSprites = $RegionSprites
	Cam = $Cam
	load_countries()
	load_regions()
#	print(RegionSprites.get_children())

func _on_button_pressed() -> void:
	print("=========> CLICK!!!")
	var clicked_country : String = get_country(get_global_mouse_position(), guess)
	if clicked_country:
		country_selected.emit(clicked_country)
