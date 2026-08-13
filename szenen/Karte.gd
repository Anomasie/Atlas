class_name Karte
extends Control

const NORMAL_COLOR : Color = Color.BLACK
const HIGHLIGHT_COLOR : Color = Color.YELLOW
const HIGHLIGHT_IN_TIME : float = 0.2
const HIGHLIGHT_OUT_TIME : float = 0.3

@onready var AllSprites
@onready var RegionSprites
@onready var Cam

var cam_dragging : bool = false
var drag_origin : Vector2
var cam_origin : Vector2

var highlighted_countries : Array = []

func _input(event: InputEvent) -> void:
	handle_input(event)

func check_country_is_clicked(node: Sprite2D, koordinaten: Vector2) -> bool:
	if not node.get_texture():
		print("ERROR in Karte.gd.check_country_is_clicked: Node invalid ", node.name)
		return false
	var image : Image = node.get_texture().get_image()
	var check_koords : Vector2i = koordinaten - node.position
	if image.get_width() > check_koords.x and check_koords.x >= 0 and image.get_height() > check_koords.y and check_koords.y >= 0:
		var color = image.get_pixel(check_koords.x, check_koords.y)
		if color == Color.WHITE:
			print("found click in ", node.name)
			return true
	return false

func handle_input(event: InputEvent) -> void:
	if not Cam:
		return
	if event.is_action_pressed("drag"):
		cam_dragging = true
		drag_origin = get_global_mouse_position()
		cam_origin = Cam.position
	elif event.is_action_released("drag"):
		cam_dragging = false
	elif cam_dragging and event is InputEventMouseMotion:
		Cam.position = cam_origin + (drag_origin - get_global_mouse_position())
	elif event.is_action_pressed("zoom_in"):
		Cam.zoom *= 1.1
	elif event.is_action_pressed("zoom_out"):
		Cam.zoom /= 1.1

func get_country(koordinaten: Vector2, guess:String = "") -> String:
	print("get country, guess: ", guess)
	if not AllSprites.get_node(guess):
		print("ERROR in Karte.gd.get_country: No guess node existing named ", guess)
	if guess and AllSprites.get_node(guess) is Sprite2D and check_country_is_clicked(AllSprites.get_node(guess), koordinaten):
		print("clicked on guess!")
		return guess
	print("get country not guess")
	if RegionSprites and RegionSprites.get_children():
		print("search by region!")
		for region in RegionSprites.get_children():
			print("check ", region.name)
			if region.visible and region is Sprite2D and check_country_is_clicked(region, koordinaten):
				print("search in region ", region.name)
				return get_country_in_region(region.name, koordinaten)
	else:
		print("search without region")
		for kid in AllSprites.get_children():
			if kid.visible and kid is Sprite2D and check_country_is_clicked(kid, koordinaten):
				return kid.name
		print("ERROR Karte.gd.get_country(): Country not found")
	return ""

func get_country_in_region(region: String, koordinaten):
	print("checking now in ", region)
	for country in Global.countries_by_region[region].keys():
		print("checking:::: ", country)
		if not AllSprites.get_node(country):
			print("ERROR in Karte.gd.get_country_in_region: No node exists named ", country)
		if check_country_is_clicked(
			AllSprites.get_node(country),
			koordinaten
		):
			print("clicked on ", country, "!")
			return country
	return ""

func highlight(list_of_countries:Array=[], highlight_color: Color = HIGHLIGHT_COLOR) -> void:
	if not list_of_countries:
		return
	var tween : Tween = get_tree().create_tween()
	for country in list_of_countries:
		if AllSprites.has_node(country):
			highlighted_countries.append(country)
			tween.tween_property(AllSprites.get_node(country), "self_modulate", highlight_color, HIGHLIGHT_IN_TIME)
	await tween.finished
	tween.kill()
	return

func hide_highlight() -> void:
	if not highlighted_countries:
		return
	# anti-highlight all
	var tween : Tween = get_tree().create_tween()
	for country in highlighted_countries:
		tween.tween_property(AllSprites.get_node(country), "self_modulate", NORMAL_COLOR, HIGHLIGHT_OUT_TIME)
	highlighted_countries = []
	await tween.finished
	tween.kill()
	return

func load_countries(to_add_ones : Array = []) -> void:
	for kid in AllSprites.get_children():
		kid.hide()
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if len(item.split("-")) > 1:
			var item_name : String = item.split("-")[1]
			if item.ends_with(".png") and (len(to_add_ones) == 0 or item_name in to_add_ones):
				if not AllSprites.has_node(item):
					var new_texture = Sprite2D.new()
					new_texture.set_texture( load("res://karten/weltkarte/"+item) )
					new_texture.set_name(item_name)
					new_texture.self_modulate = NORMAL_COLOR
					new_texture.material = self.material
					new_texture.centered = false
#					new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
					AllSprites.add_child(new_texture)
#					print("set name ", item_name, " at \t ", new_texture.name, "\t with no ", item)
				else:
					AllSprites.get_node(item).show()

func load_regions() -> void:
	var dir = DirAccess.open("res://karten/regionen")
	var file_names = dir.get_files()
	for item in file_names:
		if len(item.split("-")) > 1:
#			print("thinking about adding ", item)
			var item_name : String = item.split("-")[1]
			if item.ends_with(".png"):
				var new_texture = Sprite2D.new()
				new_texture.set_texture( load("res://karten/regionen/"+item) )
				new_texture.set_name(item_name)
				new_texture.self_modulate = NORMAL_COLOR
				new_texture.material = self.material
				new_texture.centered = false
#				new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
				RegionSprites.add_child(new_texture)
#				print("set name ", item_name, " at \t ", new_texture.name, "\t with no ", item)

func random_cohesive_countries(start_country:String = "", length=6) -> Array:
	while not start_country or not Global.countries[start_country]["Neighbors"]:
		start_country = Global.countries.keys().pick_random()
	var result : Array = [start_country]
#	print("start with: ", start_country)
	for _i in length - 1:
		var new_entry : String = start_country
		while new_entry in result:
			var key : String = result.pick_random()
			if not new_entry in Global.countries.keys():
				print("ERROR: ", key, " not in Global.countries!")
			else:
				new_entry = Global.countries[key]["Neighbors"].pick_random()
#		print("add: ", new_entry)
		result.append(new_entry)
	return result
