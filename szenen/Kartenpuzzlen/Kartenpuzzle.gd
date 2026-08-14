extends Control

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

func _ready() -> void:
	CountryContainer.hide()
	load_difficulty(DifficultyOption.get_selected_id())
	run_game()

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
		await puzzle()

func puzzle(load_country_names : PackedStringArray = Weltkarte.random_cohesive_countries()) -> void:
	##### PREPARATION
	# load countries
	Weltkarte.load_countries(load_country_names)
	Weltkarte.shuffle()
	##### await player finishing
	while not Weltkarte.solved():
		await Weltkarte.check_whether_right
	# tweak until actually right
	await Weltkarte.tweak_right()
	await self_ok()
	##### delete old ones
	Weltkarte.hide_all()

func self_ok() -> void:
	await Global.wait(0.25)
	OKButton.show()
	await ok
	OKButton.hide()
	return

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

func _on_puzzlekarte_unselected(country : String) -> void:
	pass
	#CountryContainer.hide()
