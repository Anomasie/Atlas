extends Control

signal country_selected

const NORMAL_COLOR : Color = Color.BLACK
const HIGHLIGHT_COLOR : Color = Color.YELLOW
const HIGHLIGHT_IN_TIME : float = 0.2
const HIGHLIGHT_OUT_TIME : float = 0.3

@onready var AllSprites = $AllSprites
@onready var Cam = $Cam

var highlighted_countries : Array = []
var dragging : bool = false
var drag_origin : Vector2
var cam_origin : Vector2

func _ready() -> void:
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if item.ends_with(".png"):
			var new_texture = Sprite2D.new()
			new_texture.set_texture( load("res://karten/weltkarte/"+item) )
			new_texture.set_name(item.split("-")[1])
			new_texture.self_modulate = NORMAL_COLOR
			new_texture.material = self.material
			new_texture.centered = false
#			new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			AllSprites.add_child(new_texture)

func _input(event) -> void:
	if event.is_action_pressed("zoom_in"):
		Cam.zoom *= 1.1
	elif event.is_action_pressed("zoom_out"):
		Cam.zoom /= 1.1
#		if Cam.zoom.x < 1.0:
#			Cam.zoom = Vector2(1.0, 1.0)
	elif dragging and event is InputEventMouseMotion:
		Cam.position = cam_origin + (drag_origin - get_global_mouse_position())
	elif event.is_action_pressed("drag") or event.is_action_released("drag"):
		dragging = event.pressed
		drag_origin = get_global_mouse_position()
		cam_origin = Cam.position

func get_country(koordinaten: Vector2) -> String:
	for kid in AllSprites.get_children():
		if kid is Sprite2D and kid.get_texture():
			var color = kid.get_texture().get_image().get_pixel(koordinaten.x, koordinaten.y)
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


func _on_button_pressed() -> void:
	var clicked_country : String = get_country(get_global_mouse_position())
	if clicked_country:
		country_selected.emit(clicked_country)
