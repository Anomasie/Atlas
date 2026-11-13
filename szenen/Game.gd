extends Control

@onready var Hauptmenu = $Hauptmenu
@onready var Subviewport = $ViewportContainer/SubViewport

func _ready() -> void:
	open_main_menu()

func add_game(path : String):
	var instance = load(path).instantiate()
	instance.open_main_menu.connect(open_main_menu)
	instance.open_game.connect(_on_instance_open_game)
	Subviewport.add_child(instance)
	return instance

func open_main_menu() -> void:
	for kid in Subviewport.get_children():
		kid.queue_free()
	Hauptmenu.open()

func _on_hauptmenu_start_kartenpuzzle() -> void:
	Hauptmenu.close()
	add_game("res://szenen/Länderpuzzeln/Länderpuzzle.tscn")

func _on_hauptmenu_start_länderraten() -> void:
	Hauptmenu.close()
	var instance = add_game("res://szenen/Länderraten/Kontinentauswahl.tscn")
	instance.open_kontinent.connect(_on_kontinent_selected)

func _on_hauptmenu_start_länderplatzieren() -> void:
	Hauptmenu.close()
	add_game("res://szenen/Länderplatzieren/Länderplatzieren.tscn")

func _on_instance_open_game(path : String) -> void:
	add_game(path)

func _on_kontinent_selected(n : String) -> void:
	for kid in Subviewport.get_children():
		kid.queue_free()
	var instance = add_game("res://szenen/Länderraten/Länderraten.tscn")
	instance.run_game(n)
