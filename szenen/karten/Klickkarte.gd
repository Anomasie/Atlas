class_name KlickKarte
extends Karte

signal country_selected

var guess : String = ""
var maybe_start_dragging : bool = false

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
#	print(RegionSprites.get_children())

func _input(event: InputEvent) -> void:
	if maybe_start_dragging and event is InputEventMouseMotion:
		maybe_start_dragging = false
		start_dragging()
	handle_input(event)

func load_continent(kontinent : String) -> void:
	var regions : Array = Global.REGION_LIST[kontinent]
	print(regions)
	await load_countries(Global.get_countries_in_regions(regions), true)

func _on_button_pressed() -> void:
	maybe_start_dragging = false
	if not cam_dragging:
		var clicked_country : String = get_country(get_global_mouse_position(), guess)
		if clicked_country:
			country_selected.emit(clicked_country)
	else:
		cam_dragging = false


func _on_button_button_down() -> void:
	maybe_start_dragging = true
