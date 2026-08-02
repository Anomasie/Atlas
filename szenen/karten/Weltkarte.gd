extends Karte

signal country_selected

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
	load_countries()

func _on_button_pressed() -> void:
	var clicked_country : String = get_country(get_global_mouse_position())
	if clicked_country:
		country_selected.emit(clicked_country)
