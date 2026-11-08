extends Karte
class_name Puzzlekarte

signal check_whether_right
signal selected
signal unselected

var SELECTION_COLOR = Color.DARK_GRAY
const EPSILON = 10.0
const TWEAK_TIME = 1.0

var dragging_country : String = ""
var con_origin : Vector2

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam

func _input(event) -> void:
	handle_input_click(event)

func handle_input_click(event) -> void:
	handle_input(event)
	
	if event.is_action_pressed("click"):
		var country = get_country(get_global_mouse_position())
		if AllSprites.has_node(country):
			dragging_country = country
			selected.emit(country)
			drag_origin = get_global_mouse_position()
			con_origin = AllSprites.get_node(dragging_country).position
			highlight([country], SELECTION_COLOR)
	elif event.is_action_released("click"):
		unselected.emit(dragging_country)
		dragging_country = ""
		check_whether_right.emit()
		hide_highlight()
	elif dragging_country and event is InputEventMouseMotion:
		AllSprites.get_node(dragging_country).position = con_origin + (get_global_mouse_position() - drag_origin)

func hide_all() -> void:
	for sprite in AllSprites.get_children():
		sprite.hide()

func right_position(country_position, origin:Vector2 = Vector2.ZERO) -> bool:
	if (country_position - origin).length() > EPSILON:
		return false
	else:
		return true

func shuffle(rotating : bool = true) -> void:
	var counter : int = 0
	# shuffle a bit
	for sprite in AllSprites.get_children():
		if sprite.visible:
			if sprite.name in Global.countries.keys():
				sprite.position = self.size/2 - Vector2(Global.countries[sprite.name]["Rect"].position + Global.countries[sprite.name]["Rect"].size / 2)
				if rotating:
					sprite.position += Vector2(150, 0).rotated(9.0 * counter)
				counter += 1
			else:
				print("ERROR in Puzzlekarte.shuffle: Country named ", sprite.name, " not found in Global.countries")
#		else:
#			print("WARNING in Puzzlekarte.shuffle: Not rotating node ", sprite.name, " because not visible right now")

func solved(origin : Vector2 = Vector2(-100,-100)) -> bool:
	if origin == Vector2(-100,-100):
		if AllSprites.get_children():
			origin = AllSprites.get_child(0).position
		else:
			return false
	
	for sprite in AllSprites.get_children():
		if sprite.visible and not right_position(sprite.position, origin):
			return false
	return true

func tweak_right(countries : Array, origin : Vector2) -> void:
	var b : bool = false
	var tween : Tween = get_tree().create_tween()
	for kid in countries:
		if kid.visible:
			tween.tween_property(kid, "position", origin, HIGHLIGHT_IN_TIME)
			b = true
		else:
			kid.position = origin
	if b:
		await tween.finished
	tween.kill()

func tweak_right_relative_to(to:String = "", countries: Array = AllSprites.get_children()) -> void:
	if to and AllSprites.has_node(to) and AllSprites.get_node(to):
		await tweak_right(countries, AllSprites.get_node(to).position)
	else:
		await tweak_right(countries, countries[-1].position)

func tweak_right_zero(origin:Vector2 = Vector2.ZERO, countries:Array = AllSprites.get_children()) -> void:
	await tweak_right(countries, origin)
