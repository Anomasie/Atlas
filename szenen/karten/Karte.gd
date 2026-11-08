class_name Karte
extends Control

const NORMAL_COLOR : Color = Color.BLACK
const HIGHLIGHT_COLOR : Color = Color.YELLOW
const HIGHLIGHT_IN_TIME : float = 0.2
const HIGHLIGHT_OUT_TIME : float = 0.3

@onready var AllSprites
@onready var Cam

var cam_dragging : bool = false
var drag_origin : Vector2
var cam_origin : Vector2

var highlighted_countries : Array = []

var all_sprites : Array[Node] = []

func check_country_is_clicked(node: Sprite2D, koordinaten: Vector2) -> bool:
	if not node:
		print("ERROR in Karte.gd.check_country_is_clicked: No node given")
		return false
	elif not node.get_texture():
		print("ERROR in Karte.gd.check_country_is_clicked: Node invalid ", node.name)
		return false
	# check Ländergrößen first:
	var country_position : Rect2i = Rect2i(0,0,0,0)
	if node.name in Global.countries.keys():# and "Rect" in Global.countries[node.name].keys():
		country_position = Global.countries[node.name]["Rect"]
	else:
		print("ERROR in Karte.gd.check: ", node.name, " has no Ländergröße")
		return false
	var check_koords : Vector2i = koordinaten - node.position
	if check_koords.x > country_position.position.x and check_koords.x < country_position.position.x + country_position.size.x:
		if check_koords.y > country_position.position.y and check_koords.y < country_position.position.y + country_position.size.y:
			var image : Image = node.get_texture().get_image()
			var color = image.get_pixel(check_koords.x, check_koords.y)
			if color == Color.WHITE:
				return true
	return false

func handle_input(event: InputEvent) -> void:
	if not Cam:
		return
	if event.is_action_pressed("drag"):
		start_dragging()
	elif event.is_action_released("drag"):
		cam_dragging = false
	elif cam_dragging and event is InputEventMouseMotion:
		Cam.position = cam_origin + (drag_origin - get_global_mouse_position())
	elif event.is_action_pressed("zoom_in") or event is InputEventMagnifyGesture:
		Cam.zoom *= 1.1
		$ColorRect.show()
	elif event.is_action_pressed("zoom_out") or event is InputEventPanGesture:
		Cam.zoom /= 1.1
		$ColorRect.hide()

func start_dragging() -> void:
	cam_dragging = true
	drag_origin = get_global_mouse_position()
	cam_origin = Cam.position

func get_country(koordinaten: Vector2, guess:String = "") -> String:
	if guess and not AllSprites.get_node(guess):
		print("ERROR in Karte.gd.get_country: No guess node existing named ", guess)
	if guess and AllSprites.get_node(guess) is Sprite2D and check_country_is_clicked(AllSprites.get_node(guess), koordinaten):
#		print("clicked on guess!")
		return guess
#	print("get country differing from guess")
	for kid in all_sprites:
		if kid.visible and kid is Sprite2D:
			if check_country_is_clicked(kid, koordinaten):
				return kid.name
	print("ERROR Karte.gd.get_country(), instance ", self.name, ": No country found")
	return ""

func get_country_in_region(region: String, koordinaten):
#	print("checking now in ", region)
	for country in Global.countries_by_region[region].keys():
#		print("checking:::: ", country)
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

func load_countries(to_add_ones : Array = [], should_wait : bool = true) -> void:
	for kid in AllSprites.get_children():
#		print("hide ", kid.name)
		kid.hide()
#	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = ResourceLoader.list_directory("res://karten/weltkarte") #dir.get_files()
	var counter : int = 0
	for item in file_names:
		if len(item.split("-")) > 1:
			var item_name : String = item.split("-")[1]
			if item.ends_with(".png") and (len(to_add_ones) == 0 or item_name in to_add_ones):
				if not AllSprites.has_node(item_name):
					var new_texture
					new_texture = Sprite2D.new()
					new_texture.set_texture( load("res://karten/weltkarte/"+item) )
					new_texture.set_name(item_name)
					new_texture.self_modulate = NORMAL_COLOR
					new_texture.material = self.material
					new_texture.centered = false
#					new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
					AllSprites.add_child(new_texture)
#					print("set name ", item_name, " at \t ", new_texture.name, "\t with no ", item)
				elif item_name:
					AllSprites.get_node(item_name).show()
		counter += 1
		if should_wait and counter % 30 == 0:
			await get_tree().process_frame
	if should_wait:
		await get_tree().process_frame
	all_sprites = AllSprites.get_children()

func random_cohesive_countries(start_country:String = "", length=6) -> Array:
	while not ( start_country and Global.countries[start_country]["Neighbors"] and len(Global.countries[start_country]["Neighbors"]) > 2 ):
		start_country = Global.countries.keys().pick_random()
#	print("start country in Karte.gd: ", start_country, " has neighbors ", Global.countries[start_country]["Neighbors"] )
	var result : Array = [start_country]
#	print("start with: ", start_country)
	for _i in length - 1:
		var new_entry : String = start_country
		var counter : int = 0
		while new_entry in result and counter < 100:
			counter += 1
			var key : String = result.pick_random()
			if not new_entry in Global.countries.keys():
				print("ERROR in Karte.random_cohesive_countries: ", new_entry, " not in Global.countries!")
			if not key in Global.countries.keys():
				print("ERROR in Karte.random_cohesive_countries: ", key, " not in Global.countries!")
				break
			new_entry = Global.countries[key]["Neighbors"].pick_random()
#		print("add: ", new_entry)
		result.append(new_entry)
	return result
