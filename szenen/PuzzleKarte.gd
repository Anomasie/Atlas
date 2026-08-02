extends Karte
class_name PuzzleKarte

signal check_whether_right
signal open_main_menu

var SELECTION_COLOR = Color.WHITE
const EPSILON = 10.0
const TWEAK_TIME = 1.0

var dragging_country : String = ""
var con_origin : Vector2

func open() -> void:
	show()

func close() -> void:
	self.queue_free()

func handle_input_click(event) -> void:
	handle_input(event)
	
	if event.is_action_pressed("click"):
		var country = get_country(get_global_mouse_position())
		if AllSprites.has_node(country):
			dragging_country = country
			drag_origin = get_global_mouse_position()
			con_origin = AllSprites.get_node(dragging_country).position
			highlight([country], SELECTION_COLOR)
	elif event.is_action_released("click"):
		dragging_country = ""
		check_whether_right.emit()
		hide_highlight()
	elif dragging_country and event is InputEventMouseMotion:
		AllSprites.get_node(dragging_country).position = con_origin + (get_global_mouse_position() - drag_origin)

func solved(origin : Vector2 = Vector2.ZERO) -> bool:
	for sprite in AllSprites.get_children():
		if (sprite.position - origin).length() > EPSILON:
			return false
	return true

func tweak_right(origin:Vector2 = Vector2.ZERO) -> void:
	var tween : Tween = get_tree().create_tween()
	for kid in AllSprites.get_children():
		tween.tween_property(kid, "position", origin, HIGHLIGHT_IN_TIME)
	await tween.finished
	tween.kill()

func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()
