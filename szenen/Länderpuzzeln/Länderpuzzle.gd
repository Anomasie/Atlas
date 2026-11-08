extends Control

signal finish_turn
signal ok
signal open_main_menu

const DIFFICULTY_PATHS : Array = [
	"res://karten/Drüberlegen/EigentlicheKarte-Politisch-3.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-2.png",
	""
]

var continue_game : bool = true
@onready var CountryContainer = $CanvasLayer/Control/LabelContainer
@onready var CountryLabel = $CanvasLayer/Control/LabelContainer/CountryLabel
@onready var OKButton = $CanvasLayer/Control/OKButton
@onready var DifficultyOption = $CanvasLayer/Control/Options/Lines/DifficultyOption
@onready var BackgroundKarte = $Karte
@onready var Weltkarte = $Puzzlekarte
@onready var RegionSelection = $CanvasLayer/Control/Regionsauswahl/RegionSelection
@onready var NextButton = $CanvasLayer/Control/NextButton

var active_regions : Array[String] = ["Orient"]
var possible_start_countries : Array[String] = []

func _ready() -> void:
	OKButton.hide()
	CountryContainer.hide()
	load_difficulty(DifficultyOption.get_selected_id())
	update_active_regions()
	run_game()

func _input(event) -> void:
	if event.is_action_pressed("click"):
		ok.emit()

func open() -> void:
	show()

func close() -> void:
	self.queue_free()

func load_difficulty(index : int = DifficultyOption.get_selected_id()) -> void:
	if DIFFICULTY_PATHS[index]:
		BackgroundKarte.set_texture(
			load(DIFFICULTY_PATHS[index])
		)
		BackgroundKarte.show()
	else:
		BackgroundKarte.hide()

func run_game() -> void:
	while continue_game:
		var puzzle_countries : PackedStringArray = Weltkarte.random_cohesive_countries(
			possible_start_countries.pick_random()
		)
		await puzzle(puzzle_countries)

func puzzle(load_country_names : PackedStringArray) -> void:
	##### PREPARATION
	NextButton.hide()
	# load countries
	Weltkarte.load_countries(load_country_names, false)
	Weltkarte.shuffle(true)
	##### await player finishing
	while not Weltkarte.solved():
		await Weltkarte.check_whether_right
	# tweak until actually right
	NextButton.show()
	await get_tree().process_frame
	self_ok(load_country_names)
	await finish_turn
	##### delete old ones
	Weltkarte.hide_all()

func self_ok(load_country_names) -> void:
	await Weltkarte.tweak_right_relative_to(load_country_names[0])
	OKButton.show()
	await ok
	OKButton.hide()
	finish_turn.emit()

func update_active_regions(new_regions : Array[String] = RegionSelection.get_active_regions()) -> void:
	active_regions = new_regions
	possible_start_countries = Global.get_countries_in_regions(active_regions)

func _on_back_pressed() -> void:
	self.open_main_menu.emit()
	queue_free()

func _on_ok_button_pressed() -> void:
	ok.emit()

func _on_difficulty_option_item_selected(index: int) -> void:
	load_difficulty(index)


func _on_puzzlekarte_selected(country : String) -> void:
	CountryLabel.text = Global.get_country_name(country)
	CountryContainer.show()

func _on_puzzlekarte_unselected(_country : String) -> void:
	pass
	#CountryContainer.hide()

func _on_auflosung_pressed() -> void:
	await Weltkarte.tweak_right_relative_to()
	Weltkarte.check_whether_right.emit()

func _on_region_selection_regions_changed(new_regions : Array[String]) -> void:
	update_active_regions(new_regions)


func _on_next_button_pressed() -> void:
	finish_turn.emit()

func _on_zoom_in_pressed() -> void:
	Weltkarte.Cam.zoom *= 1.5

func _on_zoom_out_pressed() -> void:
	Weltkarte.Cam.zoom /= 1.5

func _on_original_button_pressed() -> void:
	Weltkarte.Cam.zoom = Vector2(1.0, 1.0)
	Weltkarte.Cam.position = get_viewport_rect().size/2
