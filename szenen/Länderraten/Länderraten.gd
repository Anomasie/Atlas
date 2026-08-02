extends Control

const NO_START_COUNTRIES : int = 3
var country_list : Array = []

@onready var Aufgabe = $Aufgabe
@onready var Weltkarte = $Weltkarte

var continue_game : bool = true

func _ready() -> void:
	load_country_list()
	run_game()

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
	print("here: ", minimum_args)
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
		Aufgabe.text = goal
		##### PLAYER'S TURN
		# await player's choice
		var choice : String = await Weltkarte.country_selected
		last_choice = choice
		##### EVALUATION
		# compare choice with goal
		if choice == goal:
			current_countries[goal] += 1
		else:
			current_countries[goal] -= 1
			# add choice to current_countries
			if not choice in current_countries.keys():
				current_countries[choice] = -1
			else:
				current_countries[choice] -= 1
			# add a similar sounding coutnry to current_countries
			var similar_one : String = similar_sounding_countries(country_list, goal).pick_random()
			if not similar_one in current_countries.keys():
				current_countries[similar_one] = -1

func similar_sounding_countries(choose_out_of:Array, country: String) -> Array:
	var result : Array = []
	choose_out_of.erase(country)
	for key in choose_out_of:
		if country.left(3) == key.left(3) or country.right(4) == key.right(4):
			result.append(key)
	return result
