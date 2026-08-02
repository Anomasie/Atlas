extends Control

signal ok
signal open_main_menu

const NO_START_COUNTRIES : int = 3
const RIGHT_COLOR : Color = Color.BLUE
const WRONG_COLOR : Color = Color.GREEN
var country_list : Array = []

@onready var Aufgabe = $Top/Control/Results/Lines/Aufgabe
@onready var Angeklickt = $Top/Control/Results/Lines/Angeklickt
@onready var Weltkarte = $Weltkarte
@onready var OKButton = $Top/Control/Button

var continue_game : bool = true

func _ready() -> void:
	OKButton.hide()
	Angeklickt.text = ""
	Aufgabe.text = ""
	load_country_list()
	run_game()

func open() -> void:
	show()

func close() -> void:
	self.queue_free()

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

func load_country_list() -> void:
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if item.ends_with(".png"):
			var poss_name : String = item.split("-")[1]
			if poss_name:
				country_list.append(poss_name)

func run_game() -> void:
	# choose start countries
	var current_countries : Dictionary = {}
	while len(current_countries.keys()) < NO_START_COUNTRIES:
		var next_country : String = country_list.pick_random()
		if not next_country in current_countries.keys():
			current_countries[next_country] = -1
	
	var last_goal : String = ""
	var last_choice : String = ""
	while continue_game:
		##### CHOOSE GOAL
		# erase last country
		var choose_out_of : Array = country_list
		choose_out_of.erase(last_goal)
		choose_out_of.erase(last_choice)
		# pick next goal
		var goal : String = least_known_countries(choose_out_of, current_countries).pick_random()
		last_goal = goal
		# add goal to current_countries
		if not goal in current_countries.keys():
			current_countries[goal] = -1
		##### SHOW GOAL
		# show goal
		Aufgabe.text = "Finde " + goal + "!"
		##### PLAYER'S TURN
		# await player's choice
		var choice : String = await Weltkarte.country_selected
		last_choice = choice
		##### EVALUATION
		# compare choice with goal
		if choice == goal:
			current_countries[goal] += 1
			Angeklickt.text = "Richtig! Das ist "+choice+"!"
			### show highlight
			await Weltkarte.highlight([goal], RIGHT_COLOR)
		else:
			current_countries[goal] -= 1
			Angeklickt.text = "Nein, das ist "+choice+"."
			
			Weltkarte.highlight([goal], RIGHT_COLOR)
			await Weltkarte.highlight([choice], WRONG_COLOR)
			# add choice to current_countries
			if not choice in current_countries.keys():
				current_countries[choice] = -1
			else:
				current_countries[choice] -= 1
			# add a similar sounding coutnry to current_countries
			var similar_one : String = similar_sounding_countries(country_list, goal).pick_random()
			if similar_one and not similar_one in current_countries.keys():
				current_countries[similar_one] = -1
		await self_ok()
		await Weltkarte.hide_highlight()
		Angeklickt.text = ""
		Aufgabe.text = ""

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

func _on_button_pressed() -> void:
	ok.emit()

func _on_back_pressed() -> void:
	open_main_menu.emit()
	close()
