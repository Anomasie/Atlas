extends PuzzleKarte

func _ready() -> void:
	AllSprites = $AllSprites
	Cam = $Cam
	puzzle()

func _input(event) -> void:
	handle_input_click(event)

func puzzle(load_country_names : PackedStringArray = ["Niger", "Nigeria", "Tschad", "Kamerun"]) -> void:
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
	await tweak_right(AllSprites.get_child(0).position)
	$CanvasLayer/Control/Label2.text = "FINISHED!"

func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()
