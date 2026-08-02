extends PuzzleKarte

var continue_game : bool = true

func _ready() -> void:
	SELECTION_COLOR = Color.BLUE
	AllSprites = $AllSprites
	Cam = $Cam
	run_game()

func _input(event) -> void:
	handle_input_click(event)

func puzzle(load_country_name: String = Global.countries.keys().pick_random()) -> void:
	##### PREPARATION
	# load countries
	load_countries([load_country_name])
	$Top/Control/Label.text = Global.countries[load_country_name]["German"]
	# shuffle a bit
	for sprite in AllSprites.get_children():
		sprite.position += Vector2(randf()*200, randf()*200)
	##### await player finishing
	while not solved():
		await check_whether_right
	# tweak until actually right
	await tweak_right(Vector2.ZERO)

func run_game() -> void:
	while continue_game:
		await puzzle()
		# reset
		for kid in AllSprites.get_children():
			kid.queue_free()

func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()
