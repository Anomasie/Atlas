extends PuzzleKarte


func _ready() -> void:
	SELECTION_COLOR = Color.BLUE
	AllSprites = $AllSprites
	puzzle()

func _input(event) -> void:
	handle_input_click(event)

func puzzle(load_country_name: String = "Mosambik") -> void:
	##### PREPARATION
	# load countries
	load_countries([load_country_name])
	# shuffle a bit
	for sprite in AllSprites.get_children():
		sprite.position += Vector2(randf()*200, randf()*200)
	##### await player finishing
	while not solved():
		await check_whether_right
	# tweak until actually right
	await tweak_right(Vector2.ZERO)

func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()
