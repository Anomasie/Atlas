extends Control

signal open_main_menu
signal open_kontinent

@onready var Kontintente = $Margin/Lines/Kontinente.get_children()

func _ready() -> void:
	for kon in Kontintente:
		kon.pressed.connect(_on_kon_pressed.bind(kon.name))

func _on_back_pressed() -> void:
	open_main_menu.emit()

func _on_kon_pressed(n: String) -> void:
	open_kontinent.emit(n)
