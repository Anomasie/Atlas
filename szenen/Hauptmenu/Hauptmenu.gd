extends Control

signal start_länderraten
signal start_kartenpuzzle
signal start_länderplatzieren

@onready var RegionSelection = $Screen/RegionSelection
@onready var BeendenButton = $Screen/Lines/Beenden

func _ready() -> void:
	BeendenButton.visible = not OS.has_feature("web")

func open() -> void:
	RegionSelection.load_player_data()
	show()

func close() -> void:
	hide()

func _on_länderraten_pressed() -> void:
	start_länderraten.emit()

func _on_kartenpuzzle_pressed() -> void:
	start_kartenpuzzle.emit()

func _on_länderplatzieren_pressed() -> void:
	start_länderplatzieren.emit()


func _on_beenden_pressed() -> void:
	get_tree().quit()
