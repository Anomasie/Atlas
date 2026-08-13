extends Control

signal ok
signal open_main_menu

const NO_START_COUNTRIES : int = 3
const RIGHT_COLOR : Color = Color.DIM_GRAY
const WRONG_COLOR : Color = Color.GREEN_YELLOW

@onready var Aufgabe = $Top/Control/Results/Lines/Aufgabe
@onready var Angeklickt = $Top/Control/Results/Lines/Angeklickt
@onready var Weltkarte = $Weltkarte
@onready var OKButton = $Top/Control/Button
@onready var BackgroundKarte = $Karte
@onready var DifficultyOption = $Top/Control/Options/Lines/DifficultyOption
@onready var GelernteCounter = $Top/Control/Statistik/Grid/GelernteCounter
@onready var FehlendeCounter = $Top/Control/Statistik/Grid/FehlendeCounter

const DIFFICULTY_PATHS : Array = [
	"res://karten/Drüberlegen/EigentlicheKarte-Politisch-3.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-2.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-1.png"
]

var continue_game : bool = true

func _ready() -> void:
	OKButton.hide()
	Angeklickt.text = ""
	Aufgabe.text = ""
	run_game()

func open() -> void:
	show()

func close() -> void:
	self.queue_free()

func get_active_countries(list_of_countries: Dictionary, duplicate_by_unknownness:bool = true) -> Array:
	var list : Array[String] = []
	for key in list_of_countries.keys():
		if list_of_countries[key] < 0:
			if duplicate_by_unknownness:
				for i in -list_of_countries[key]:
					list.append(key)
			else:
				list.append(key)
	return list

func get_known_countries(list_of_countries: Dictionary) -> Array:
	var list : Array[String] = []
	for key in list_of_countries.keys():
		if list_of_countries[key] >= 0:
			list.append(key)
	return list

func get_unknown_countries(known_countries: Dictionary) -> Array:
	var list : Array[String] = []
	for key in Global.countries.keys():
		if key not in known_countries.keys():
			list.append(key)
	return list

func least_known_countries(list_of_countries : Array, current_countries : Dictionary) -> Array:
	var minimum : int = 0
	var minimum_args : Array = []
	for key in list_of_countries:
		if key in current_countries.keys():
			if current_countries[key] < minimum:
				minimum_args = [key]
				minimum = current_countries[key]
			elif current_countries[key] == minimum:
				minimum_args.append(key)
		elif minimum == 0:
			minimum_args.append(key)
	return minimum_args

func load_difficulty(index : int = DifficultyOption.get_selected_id()) -> void:
	BackgroundKarte.set_texture(
		load(DIFFICULTY_PATHS[index])
	)

func run_game() -> void:
	# choose start countries
	var current_countries : Dictionary = {}
	update_ui(current_countries)
	while len(current_countries.keys()) < NO_START_COUNTRIES:
		var next_country : String = Global.countries.keys().pick_random()
		if not next_country in current_countries.keys():
			current_countries[next_country] = -1
	
	var last_goal : String = ""
	var last_choice : String = ""
	while continue_game:
		print("Current Countries: ", current_countries, "\nActive Countries: ", get_active_countries(current_countries, true))
		##### CHOOSE GOAL
		# erase last country
		var choose_out_of : Array = get_active_countries(current_countries, true)
		choose_out_of.erase(last_goal)
		choose_out_of.erase(last_choice)
		# pick next goal
		var goal : String = choose_out_of.pick_random() #least_known_countries(choose_out_of, current_countries).pick_random()
		last_goal = goal
		# add goal to current_countries
		if not goal in current_countries.keys():
			current_countries[goal] = -1
		##### SHOW GOAL
		# show goal
		Aufgabe.text = "Finde " + Global.get_country_name(goal) + "!"
		Weltkarte.guess = goal
		##### PLAYER'S TURN
		# await player's choice
		var choice : String = await Weltkarte.country_selected
		last_choice = choice
		##### EVALUATION
		# compare choice with goal
#		print(choice, ", ", goal)
		if choice == goal:
			current_countries[goal] /= 2
			Angeklickt.text = "Richtig! Das ist "+Global.get_country_name(choice)+"!"
			### show highlight
			await Weltkarte.highlight([goal], RIGHT_COLOR)
		else:
			current_countries[goal] -= 1
			Angeklickt.text = "Nein, das ist "+Global.get_country_name(choice)+"."
			
			Weltkarte.highlight([goal], RIGHT_COLOR)
			await Weltkarte.highlight([choice], WRONG_COLOR)
			# add choice to current_countries
			if not choice in current_countries.keys():
				current_countries[choice] = -1
			else:
				current_countries[choice] -= 1
			# add a similar sounding coutnry to current_countries
			var similar_one : String = similar_sounding_countries(Global.countries.keys(), goal).pick_random()
			if similar_one and not similar_one in current_countries.keys():
				current_countries[similar_one] = -1
			# all countries known
		##### change ui
		update_ui(current_countries)
		##### CLOSE
		await self_ok()
		await Weltkarte.hide_highlight()
		Angeklickt.text = ""
		Aufgabe.text = ""
		##### END GAME?
		if len(get_known_countries(current_countries)) == len(Global.countries.keys()):
			continue_game = false
		# if not enough current_countries: add one
		while len(get_active_countries(current_countries, false)) < 4 and get_unknown_countries(current_countries):
			print("add country! ", get_active_countries(current_countries, false), " has length smaller than 4.")
			current_countries[get_unknown_countries(current_countries).pick_random()] = -1
		print()

func self_ok() -> void:
	await Global.wait(0.25)
	OKButton.show()
	await ok
	OKButton.hide()
	return

func similar_sounding_countries(choose_out_of:Array, country: String) -> Array:
	var result : Array = []
	choose_out_of.erase(country)
	for key in choose_out_of:
		if country.left(2) == key.left(2) or country.right(2) == key.right(2):
			result.append(key)
	if len(result) == 0:
		result = [""]
	return result

func update_ui(current_countries:Dictionary) -> void:
	GelernteCounter.text = str(len(get_known_countries(current_countries)))
	FehlendeCounter.text = str(len(get_unknown_countries(current_countries)))

func _on_button_pressed() -> void:
	ok.emit()

func _on_back_pressed() -> void:
	open_main_menu.emit()
	close()

func _on_difficulty_option_item_selected(index: int) -> void:
	load_difficulty(index)
