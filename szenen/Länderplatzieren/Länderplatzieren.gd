extends Karte

signal open_main_menu

func _ready() -> void:
	AllSprites = $AllSprites
	load_countries()

func open() -> void:
	show()

func close() -> void:
	self.queue_free()


func _on_back_pressed() -> void:
	open_main_menu.emit()
	queue_free()
