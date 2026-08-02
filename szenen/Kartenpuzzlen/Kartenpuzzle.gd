extends PuzzleKarte

signal ok

var continue_game : bool = true
@onready var OKButton = $CanvasLayer/Control/OKButton

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
	run_game()

func _input(event) -> void:
	handle_input_click(event)

func run_game() -> void:
	while continue_game:
		await puzzle()

func puzzle(load_country_names : PackedStringArray = random_cohesive_countries()) -> void:
	##### PREPARATION
	# load countries
	load_countries(load_country_names)
	# shuffle a bit
	for sprite in AllSprites.get_children():
		sprite.position += Vector2(randf()*200, randf()*200)
	##### await player finishing
	while not solved(AllSprites.get_child(0).position):
		await check_whether_right
	# tweak until actually right
	await tweak_right(AllSprites.get_children(), AllSprites.get_child(0).position)
	await self_ok()
	##### delete old ones
	for sprite in AllSprites.get_children():
		sprite.queue_free()

func self_ok() -> void:
	await Global.wait(0.25)
	OKButton.show()
	await ok
	OKButton.hide()
	return

func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()

func _on_selected(country : String) -> void:
	$CanvasLayer/Control/Label.text = country

func _on_unselected(_country : String) -> void:
	$CanvasLayer/Control/Label.text = ""

func _on_ok_button_pressed() -> void:
	ok.emit()
