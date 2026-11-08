extends Control

signal country_selected

@onready var Karten : Array[Node] = self.get_children()

var goal : String
var clicked_one : String = ""

func _ready() -> void:
	for karte in Karten:
		karte.country_selected.connect(_on_karte_country_selected)

func _process(_delta) -> void:
	if clicked_one:
		country_selected.emit(clicked_one)

func highlight(args) -> void:
	for karte in Karten:
		karte.highlight(args)

func hide_highlight() -> void:
	for karte in Karten:
		karte.hide_highlight()

func load_countries(to_add_ones : Array = [], should_wait : bool = true) -> void:
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	var counter : int = 0
	@warning_ignore("integer_division")
	var max_counter : int = len(file_names) / len(Karten) + 1
	var add_to_current_map : Array[String] = []
	var current_map : int = 0
	for item in file_names:
		if len(item.split("-")) > 1:
			var item_name : String = item.split("-")[1]
			if item.ends_with(".png") and (len(to_add_ones) == 0 or item_name in to_add_ones):
				add_to_current_map.append(item_name)
		counter += 1
		if counter > max_counter:
			await load_to_map(add_to_current_map, current_map, should_wait)
			current_map += 1
			add_to_current_map = []
			counter = 0
	if counter > 0:
		print("add rest!")
		await load_to_map(add_to_current_map, current_map, should_wait)
	if should_wait:
		await get_tree().process_frame

func load_to_map(add_to_current_map : Array[String], current_map : int, should_wait : bool = false) -> void:
	print("add ", add_to_current_map, " to map no ", current_map, " now")
	Karten[current_map].load_countries(add_to_current_map, should_wait, true)
	add_to_current_map = []
	if should_wait:
		await get_tree().process_frame

func set_goal(new_goal : String) -> void:
	goal = new_goal
	for karte in Karten:
		karte.goal = goal

func _on_karte_country_selected(args) -> void:
	if args:
		clicked_one = args
