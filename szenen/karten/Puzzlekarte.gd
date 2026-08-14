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

func shuffle() -> void:
	# shuffle a bit
	for sprite in AllSprites.get_children():
		if sprite.visible:
			sprite.position += Vector2(randf()*200, randf()*200)

func solved(origin : Vector2 = AllSprites.get_child(0).position) -> bool:
	for sprite in AllSprites.get_children():
		if sprite.visible and not right_position(sprite.position, origin):
			return false
	return true

func tweak_right(countries : Array = AllSprites.get_children(), origin:Vector2 = AllSprites.get_child(0).position) -> void:
	var tween : Tween = get_tree().create_tween()
	for kid in countries:
		tween.tween_property(kid, "position", origin, HIGHLIGHT_IN_TIME)
	await tween.finished
	tween.kill()
