extends Karte

signal check_whether_right
signal open_main_menu

const SELECTION_COLOR = Color.WHITE
const EPSILON = 10.0
const TWEAK_TIME = 1.0

var dragging_country : String = ""
var con_origin : Vector2

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
	puzzle()

func open() -> void:
	show()

func close() -> void:
	self.queue_free()

func _input(event) -> void:
	handle_input(event)
	
	if event.is_action_pressed("click"):
		var country = get_country(get_global_mouse_position())
		if AllSprites.has_node(country):
			dragging_country = country
			drag_origin = get_global_mouse_position()
			con_origin = AllSprites.get_node(dragging_country).position
			$CanvasLayer/Control/Label.text = country
			highlight([country], SELECTION_COLOR)
	elif event.is_action_released("click"):
		dragging_country = ""
		check_whether_right.emit()
		$CanvasLayer/Control/Label.text = ""
		hide_highlight()
	elif dragging_country and event is InputEventMouseMotion:
		AllSprites.get_node(dragging_country).position = con_origin + (get_global_mouse_position() - drag_origin)

func puzzle(load_country_names : PackedStringArray = ["Niger", "Nigeria", "Tschad", "Kamerun"]) -> void:
	##### PREPARATION
	# load countries
	load_countries(load_country_names)
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
			return false
	return true

func tweak_right() -> void:
	var tween : Tween = get_tree().create_tween()
	var origin = AllSprites.get_child(0).position
	for kid in AllSprites.get_children():
		tween.tween_property(kid, "position", origin, HIGHLIGHT_IN_TIME)
	await tween.finished
	tween.kill()


func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()
