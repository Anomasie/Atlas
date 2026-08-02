extends Control

signal start_länderraten
signal start_kartenpuzzle
signal start_länderplatzieren

func open() -> void:
	show()

func close() -> void:
	hide()

func _on_länderraten_pressed() -> void:
	start_länderraten.emit()

func _on_kartenpuzzle_pressed() -> void:
	start_kartenpuzzle.emit()

func _on_länderplatzieren_pressed() -> void:
	start_länderplatzieren.emit()
