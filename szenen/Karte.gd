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

func _input(event: InputEvent) -> void:
	handle_input(event)

func handle_input(event: InputEvent) -> void:
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

func get_country(koordinaten: Vector2) -> String:
	for kid in AllSprites.get_children():
		if kid is Sprite2D and kid.get_texture():
			var color = kid.get_texture().get_image().get_pixel(koordinaten.x-kid.position.x, koordinaten.y-kid.position.y)
			if color == Color.WHITE:
				return kid.name
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
