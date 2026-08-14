extends Node

const REGION_LIST : Dictionary[String, Array] = {
	"Afrika": ["Westafrika", "Ostafrika", "Sahara", "Südafrika", "Zentralafrika"],
	"Europa": ["Westeuropa", "Osteuropa"],
	"Amerika": ["Nordamerika", "Karibik", "Sudamerika"],
	"Ozeanien": [],
	"Asien": ["Ostasien", "Himalaya", "Orient"]
}

var countries : Dictionary = {}
var countries_by_region : Dictionary = {}
var language : String = "German"

var selected_regions_big : Dictionary[String, bool] = {
	"Afrika": true,
	"Europa": true,
	"Amerika": true,
	"Ozeanien": true,
	"Asien": true
}

var selected_regions_small : Dictionary[String, bool] = {
	"Westafrika": true,
	"Ostafrika": true,
	"Sahara": true,
	"Südafrika": true,
	"Zentralafrika": true,
	"Westeuropa": true,
	"Osteuropa": true,
	"Nordamerika": true,
	"Karibik": false,
	"Sudamerika": true,
	"Ozeanien": true,
	"Ostasien": true,
	"Himalaya": true,
	"Orient": true
}

func _ready() -> void:
	load_country_list()

func get_countries_in_regions(regions : Array[String]) -> Array[String]:
	var allowed_countries : Array[String] = []
	for country in countries.keys():
		if countries[country]["Region"] in regions:
			allowed_countries.append(country)
	return allowed_countries

func get_country_name(load_country_name : String) -> String:
	if countries.has(load_country_name) and countries[load_country_name].has(language):
		return countries[load_country_name][language]
	else:
		return load_country_name

func load_country_list() -> void:
	var file = FileAccess.open("res://karten/Länder.csv", FileAccess.READ)
	var file_text : PackedStringArray = file.get_as_text().split("\n", false)
	var keys = file_text[0].split(";")
	file_text.remove_at(0)
	countries = {}
	countries_by_region = {}
	for row in file_text:
		var row_split = row.split(";", true)
		var this_name : String = row_split[0]
		countries[this_name] = {}
		for i in range(1,len(keys)):
			if keys[i] != "Neighbors":
				countries[this_name][keys[i]] = row_split[i]
			else:
				countries[this_name][keys[i]] = Array(row_split[i].split(","))
		# add to countries_by_region
		var this_region : String = countries[this_name]["Region"]
		if not this_region in countries_by_region.keys():
			countries_by_region[this_region] = {}
		countries_by_region[this_region][this_name] = countries[this_name]

func wait(wait_time: float = 1.0) -> void:
	if wait_time > 0:
		await await get_tree().create_timer(wait_time).timeout
		return
	else:
		await get_tree().process_frame
		return
