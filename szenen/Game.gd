extends Control

@onready var Hauptmenu = $Hauptmenu
@onready var Subviewport = $ViewportContainer/SubViewport

func _ready() -> void:
	open_main_menu()

func add_game(path : String) -> void:
	var instance = load(path).instantiate()
	instance.open_main_menu.connect(open_main_menu)
	Subviewport.add_child(instance)

func open_main_menu() -> void:
	Hauptmenu.open()

func _on_hauptmenu_start_kartenpuzzle() -> void:
	Hauptmenu.close()
	add_game("res://szenen/Länderpuzzeln/Länderpuzzle.tscn")

func _on_hauptmenu_start_länderplatzieren() -> void:
	Hauptmenu.close()
	add_game("res://szenen/Länderplatzieren/Länderplatzieren.tscn")

func _on_hauptmenu_start_länderraten() -> void:
	Hauptmenu.close()
	add_game("res://szenen/Länderraten/Länderraten.tscn")
