extends Node

var countries : Dictionary = {}

func _ready() -> void:
	load_country_list()

func load_country_list() -> void:
	var file = FileAccess.open("res://karten/Länder.csv", FileAccess.READ)
	var file_text : PackedStringArray = file.get_as_text().split("\n", false)
	var keys = file_text[0].split(";")
	file_text.remove_at(0)
	for row in file_text:
		var row_split = row.split(";", true)
		countries[row_split[0]] = {}
		for i in range(1,len(keys)):
			if keys[i] != "Neighbors":
				countries[row_split[0]][keys[i]] = row_split[i]
			else:
				countries[row_split[0]][keys[i]] = row_split[i].split(",")

func wait(wait_time: float = 1.0) -> void:
	if wait_time > 0:
		await await get_tree().create_timer(wait_time).timeout
		return
	else:
		await get_tree().process_frame
		return
