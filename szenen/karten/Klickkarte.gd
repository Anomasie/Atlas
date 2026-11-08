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
	match kontinent:
		"Afrika":
			Cam.zoom *= 2.0
			Cam.position.y += 40
		"Asien":
			Cam.zoom *= 1.5
			Cam.position.x += 500
			Cam.position.y -= 140
		"Europa":
			Cam.zoom *= 2.5
			Cam.position.y -= 250
		"Nordamerika":
			Cam.zoom *= 2.8
			Cam.position.x -= 500
			Cam.position.y -= 140
		"Sudamerika":
			Cam.zoom *= 2.0
			Cam.position.x -= 300
			Cam.position.y += 200
		"Ozeanien":
			Cam.zoom *= 2.0
			Cam.position.x += 600
			Cam.position.y += 120

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
