extends Karte

signal check_whether_right

const SELECTION_COLOR = Color.WHITE
const EPSILON = 10.0
const TWEAK_TIME = 1.0

var dragging : String = ""
var con_origin : Vector2

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
	puzzle()

func open() -> void:
	show()
	$CanvasLayer/Control.show()

func close() -> void:
	hide()
	$CanvasLayer/Control.hide()

func _input(event) -> void:
	handle_input(event)
	if event.is_action_pressed("click"):
		var country = get_country(get_global_mouse_position())
		if AllSprites.has_node(country):
			dragging = country
			drag_origin = get_global_mouse_position()
			con_origin = AllSprites.get_node(dragging).position
			$CanvasLayer/Control/Label.text = country
			highlight([country], SELECTION_COLOR)
	elif event.is_action_released("click"):
		dragging = ""
		check_whether_right.emit()
		$CanvasLayer/Control/Label.text = ""
		hide_highlight()
	elif dragging and event is InputEventMouseMotion:
		AllSprites.get_node(dragging).position = con_origin + (get_global_mouse_position() - drag_origin)

func puzzle(load_countries : PackedStringArray = ["Niger", "Nigeria", "Tschad", "Kamerun"]) -> void:
	##### PREPARATION
	# load countries
	var dir = DirAccess.open("res://karten/weltkarte")
	var file_names = dir.get_files()
	for item in file_names:
		if item.ends_with(".png") and item.split("-")[1] in load_countries:
			var new_texture = Sprite2D.new()
			new_texture.set_texture( load("res://karten/weltkarte/"+item) )
			new_texture.set_name(item.split("-")[1])
			new_texture.self_modulate = NORMAL_COLOR
#			new_texture.material = self.material
			new_texture.centered = false
#			new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			AllSprites.add_child(new_texture)
	# shuffle a bit
	for sprite in AllSprites.get_children():
		sprite.position += Vector2(randf()*200, randf()*200)
	##### await player finishing
	while not solved():
		await check_whether_right
	# tweak until actually right
	await tweak_right()
	$CanvasLayer/Control/Label2.text = "FINISHED!"

func solved() -> bool:
	var origin: Vector2 = AllSprites.get_child(0).position
	for sprite in AllSprites.get_children():
		if (sprite.position - origin).length() > EPSILON:
			print("not right by ", (sprite.position - origin).length())
			return false
	return true

func tweak_right() -> void:
	var tween : Tween = get_tree().create_tween()
	var origin = AllSprites.get_child(0).position
	for kid in AllSprites.get_children():
		tween.tween_property(kid, "position", origin, HIGHLIGHT_IN_TIME)
	await tween.finished
	tween.kill()
