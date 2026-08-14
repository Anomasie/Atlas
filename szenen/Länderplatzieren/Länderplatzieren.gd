extends Control

signal ok
signal open_main_menu

@onready var BackgroundKarte = $Karte
@onready var CountryContainer = $Top/Control/LabelContainer
@onready var CountryLabel = $Top/Control/LabelContainer/CountryLabel
@onready var DifficultyOption = $Top/Control/Options/Lines/DifficultyOption
@onready var Weltkarte = $Puzzlekarte
@onready var OKButton = $Top/Control/OKButton
@onready var RegionSelection = $Top/Control/Regionsauswahl/RegionSelection

const DIFFICULTY_PATHS : Array = [
	"res://karten/Drüberlegen/EigentlicheKarte-Politisch-3.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-2.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-1.png"
]

var active_regions : Array[String] = ["Orient"]
var possible_countries : Array[String] = []

var continue_game : bool = true

func _ready() -> void:
	Weltkarte.SELECTION_COLOR = Color.BLUE
	load_difficulty()
	update_active_regions()
	run_game()

func _input(event) -> void:
	if event.is_action_pressed("click"):
		ok.emit()

func load_difficulty(index : int = DifficultyOption.get_selected_id()) -> void:
	BackgroundKarte.set_texture(
		load(DIFFICULTY_PATHS[index])
	)

func puzzle(load_country_name: String = possible_countries.pick_random()) -> void:
	##### PREPARATION
	# load countries
	Weltkarte.load_countries([load_country_name])
	Weltkarte.shuffle()
	CountryLabel.text = Global.get_country_name(load_country_name)
	##### await player finishing
	while not Weltkarte.solved(BackgroundKarte.position):
		await Weltkarte.check_whether_right
	# tweak until actually right
	await Weltkarte.tweak_right_zero(BackgroundKarte.get_global_position())
	await self_ok()
	##### delete old ones
	Weltkarte.hide_all()

func run_game() -> void:
	while continue_game:
		await puzzle()
		# reset
		Weltkarte.hide_all()

func self_ok() -> void:
	await Global.wait(0.25)
	OKButton.show()
	await ok
	OKButton.hide()
	return

func update_active_regions(new_regions : Array[String] = RegionSelection.get_active_regions()) -> void:
	active_regions = new_regions
	possible_countries = Global.get_countries_in_regions(active_regions)

func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()

func _on_difficulty_option_item_selected(index: int) -> void:
	load_difficulty(index)


func _on_puzzlekarte_selected(country : String) -> void:
	if country in Global.countries.keys():
		CountryLabel.text = Global.get_country_name(country)
	else:
		print("ERROR in Länderplatzieren.gd._on_selected: No country named ", country)


func _on_ok_button_pressed() -> void:
	ok.emit()

func _on_auflosung_pressed() -> void:
	await Weltkarte.tweak_right_zero(BackgroundKarte.get_global_position())
	Weltkarte.check_whether_right.emit()

func _on_region_selection_regions_changed(new_regions : Array[String]) -> void:
	update_active_regions(new_regions)
