extends Control

func _ready() -> void:
	open_only("Hauptmenu")

func open_only(node_name:String) -> void:
	for node in self.get_children():
		if node.name != node_name:
			node.close()
		else:
			node.open()

func _on_hauptmenu_start_kartenpuzzle() -> void:
	open_only("Kartenpuzzle")

func _on_hauptmenu_start_länderplatzieren() -> void:
	open_only("Länderplatzieren")

func _on_hauptmenu_start_länderraten() -> void:
	open_only("Länderraten")
