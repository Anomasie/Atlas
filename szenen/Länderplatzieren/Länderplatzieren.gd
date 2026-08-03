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
	await tweak_right(AllSprites.get_children(), Vector2.ZERO)

func run_game() -> void:
	while continue_game:
		await puzzle()
		# reset
		for kid in AllSprites.get_children():
			kid.hide()



func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()

func _on_add_button_pressed() -> void:
	load_countries([Global.countries.keys().pick_random()])

func _on_selected(country : String) -> void:
	if country in Global.countries.keys():
		$Top/Control/Label.text = Global.countries[country]["German"]
	else:
		print("ERROR in Länderplatzieren.gd._on_selected: No country named ", country)

func _on_unselected(country : String) -> void:
	if not country:
		return
	if not AllSprites.has_node(country):
		print("ERROR in Länderplatzieren.gd._on_unselected: No country loaded with name ", country)
	if right_position(AllSprites.get_node(country).position):
		print("tweak! ", country)
		tweak_right([AllSprites.get_node(country)])
