extends Control

signal ok
signal open_main_menu

const NO_START_COUNTRIES : int = 3
const RIGHT_COLOR : Color = Color.DEEP_PINK
const WRONG_COLOR : Color = Color.DARK_TURQUOISE

@onready var Aufgabe = $Top/Control/Results/Lines/Aufgabe
@onready var Angeklickt = $Top/Control/Results/Lines/Angeklickt
@onready var Kontinentkarte = $Kontinentkarte
@onready var OKButton = $Top/Control/Button
@onready var BackgroundKarte = $Karte
@onready var DifficultyOption = $Top/Control/Options/Lines/DifficultyOption
@onready var GelernteCounter = $Top/Control/Statistik/Lines/Grid/GelernteCounter
@onready var FehlendeCounter = $Top/Control/Statistik/Lines/Grid/FehlendeCounter
@onready var RegionSelection = $Top/Control/Statistik/Lines/RegionSelection
@onready var LadeLabel = $Top/LadeLabel
@onready var NextButton = $Top/Control/NextButton

const DIFFICULTY_PATHS : Array = [
	"res://karten/Drüberlegen/EigentlicheKarte-Politisch-3.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-2.png",
	"res://karten/Drüberlegen/EigentlicheKarte-Physisch-1.png"
]

var active_regions : Array = ["Orient"]
var current_countries : Dictionary
var continue_game : bool = true

func _ready() -> void:
	hide()
	OKButton.hide()
	Angeklickt.text = ""
	Aufgabe.text = ""
	NextButton.hide()

func _input(event) -> void:
	if event.is_action_pressed("click"):
		ok.emit()

func open() -> void:
	show()

func close() -> void:
	self.queue_free()

func get_active_countries(list_of_countries: Dictionary, duplicate_by_unknownness:bool) -> Array:
	var list : Array[String] = []
	for key in list_of_countries.keys():
		if list_of_countries[key] < 0 and Global.countries[key]["Region"] in active_regions:
			if duplicate_by_unknownness:
				for i in -list_of_countries[key]:
					list.append(key)
			else:
				list.append(key)
	return list

func update_active_regions() -> void:
	active_regions = RegionSelection.get_active_regions()

func get_known_countries(list_of_countries: Dictionary) -> Array:
	var list : Array[String] = []
	for key in list_of_countries.keys():
		if list_of_countries[key] >= 0 and Global.countries[key]["Region"] in active_regions:
			list.append(key)
	return list

func get_new_goal(to_countries : Dictionary, last_goal:String, last_choice:String) -> String:
	var choose_out_of : Array = get_active_countries(to_countries, true)#, get_active_regions())
	if len(choose_out_of) > 0:
		choose_out_of.erase(last_goal)
	if len(choose_out_of) > 0:
		choose_out_of.erase(last_choice)
	# pick next goal
	return choose_out_of.pick_random()

func get_unknown_countries(known_countries: Dictionary) -> Array:
	var list : Array[String] = []
	for key in Global.countries.keys():
		if key not in known_countries.keys() and Global.countries[key]["Region"] in active_regions:
			list.append(key)
	return list

func least_known_countries(list_of_countries : Array, to_countries : Dictionary = current_countries) -> Array:
	var minimum : int = 0
	var minimum_args : Array = []
	for key in list_of_countries:
		if key in to_countries.keys():
			if to_countries[key] < minimum:
				minimum_args = [key]
				minimum = to_countries[key]
			elif to_countries[key] == minimum:
				minimum_args.append(key)
		elif minimum == 0:
			minimum_args.append(key)
	return minimum_args

func load_difficulty(index : int = DifficultyOption.get_selected_id()) -> void:
	BackgroundKarte.set_texture(
		load(DIFFICULTY_PATHS[index])
	)

func set_start_countries():
	update_ui(current_countries)
	var counter : int = 0
	while len(current_countries.keys()) < NO_START_COUNTRIES and counter < 50:
		var next_country : String = Global.countries_by_region[active_regions.pick_random()].keys().pick_random()
		if not Global.small_countries_ok:
			var rect : Rect2i = Global.countries[next_country]["Rect"]
			if rect.size.x < 40 or rect.size.y < 40:
				print(next_country, " too small")
				next_country = ""
		counter += 1
		if next_country and not next_country in current_countries.keys():
			current_countries[next_country] = -1
	print(current_countries)

func run_game(kontinent : String) -> void:
	active_regions = Global.REGION_LIST[kontinent]
	await Kontinentkarte.load_continent(kontinent)
	LadeLabel.hide()
	show()
	
	# choose start current_countries
	set_start_countries()
	
	var last_goal : String = ""
	var last_choice : String = ""
	while continue_game:
		print("Current Countries: ", current_countries, "\nActive Countries: ", get_active_countries(current_countries, true))#, get_active_regions()))
		##### CHOOSE GOAL
		# pick next goal
		var goal : String = get_new_goal(current_countries, last_goal, last_choice) #least_known_countries(choose_out_of, current_countries).pick_random()
		last_goal = goal
		
		# add goal to current_countries
		if not goal in current_countries.keys():
			current_countries[goal] = -1
		##### SHOW GOAL
		# show goal
		Aufgabe.text = "Finde " + Global.get_country_name(goal) + "!"
		Kontinentkarte.guess = goal
		##### PLAYER'S TURN
		# await player's choice
		var choice : String = await Kontinentkarte.country_selected
		last_choice = choice
		NextButton.show()
		##### EVALUATION
		# compare choice with goal
#		print(choice, ", ", goal)
		if choice == goal:
			current_countries[goal] /= 2
			Angeklickt.text = "Richtig! Das ist "+Global.get_country_name(choice)+"!"
			### show highlight
			await Kontinentkarte.highlight([goal], RIGHT_COLOR)
		else:
			current_countries[goal] -= 1
			Angeklickt.text = "Nein, das ist "+Global.get_country_name(choice)+"."
			
			Kontinentkarte.highlight([goal], RIGHT_COLOR)
			await Kontinentkarte.highlight([choice], WRONG_COLOR)
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
		NextButton.hide()
		await Kontinentkarte.hide_highlight()
		Angeklickt.text = ""
		Aufgabe.text = ""
		##### END GAME?
		# if not enough current_countries: add one
		while len(get_active_countries(current_countries, false)) < 4 and get_unknown_countries(current_countries):
			current_countries[get_unknown_countries(current_countries).pick_random()] = -1
		if len(get_active_countries(current_countries, true)) == 0:
			continue_game = false
			Aufgabe.text = "Herzlichen Glückwunsch! Du kennst alle Länder."
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

func update_ui(to_countries:Dictionary = current_countries) -> void:
	GelernteCounter.text = str(len(get_known_countries(to_countries)))
	FehlendeCounter.text = str(len(get_unknown_countries(to_countries)))

func _on_button_pressed() -> void:
	ok.emit()

func _on_back_pressed() -> void:
	open_main_menu.emit()
	close()

func _on_difficulty_option_item_selected(index: int) -> void:
	load_difficulty(index)


func _on_region_selection_regions_changed(new_regions) -> void:
	active_regions = new_regions
	update_ui()


func _on_zoom_in_pressed() -> void:
	Kontinentkarte.Cam.zoom *= 1.5

func _on_zoom_out_pressed() -> void:
	Kontinentkarte.Cam.zoom /= 1.5

func _on_original_button_pressed() -> void:
	
	Kontinentkarte.Cam.zoom = Vector2(1.0, 1.0)
	Kontinentkarte.Cam.position = get_viewport_rect().size/2
