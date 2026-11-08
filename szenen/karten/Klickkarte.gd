class_name KlickKarte
extends Karte

signal country_selected

var guess : String = ""

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
#	print(RegionSprites.get_children())

func load_continent(kontinent : String) -> void:
	var regions : Array = Global.REGION_LIST[kontinent]
	print(regions)
	await load_countries(Global.get_countries_in_regions(regions), true)

func _on_button_pressed() -> void:
	var clicked_country : String = get_country(get_global_mouse_position(), guess)
	if clicked_country:
		country_selected.emit(clicked_country)
