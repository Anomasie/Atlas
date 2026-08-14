extends Control

signal regions_changed

@onready var Grid = $FoldableContainer/Grid
@onready var RegionCheckBoxes : Array[CheckBox]
@onready var RegionCheckMenus : Array[VBoxContainer]
#@onready var NestedCheckBoxes : Array[CheckBox]

func _ready() -> void:
	load_region_checkboxes()
	load_player_data()

func get_active_regions() -> Array[String]:
	var result : Array[String] = []
	for i in len(RegionCheckBoxes):
		if RegionCheckBoxes[i].button_pressed and len(RegionCheckMenus) > i:
			for element in RegionCheckMenus[i].get_children():
				if element.button_pressed:
					result.append(element.text)
	print(result)
	if not result:
		print("ERROR in RegionSelection.gd: No regions selected!")
		return []
	else:
		return result

func load_player_data() -> void:
	for big_region in RegionCheckBoxes:
		big_region.button_pressed = Global.selected_regions_big[big_region.name]
	for small_region_menu in RegionCheckMenus:
		for small_region in small_region_menu.get_children():
			small_region.button_pressed = Global.selected_regions_small[small_region.name]

func load_region_checkboxes() -> void:
	for region in Global.REGION_LIST:
		# add checkbox
		var new_checkbox : CheckBox = CheckBox.new()
		new_checkbox.name = region
		new_checkbox.pressed.connect(_on_regions_changed)
		new_checkbox.button_pressed = true
		Grid.add_child(new_checkbox)
		RegionCheckBoxes.append(new_checkbox)
		# add label (i. e. MenuButton)
		var new_menu : FoldableContainer = FoldableContainer.new()
		var new_menu_lines : VBoxContainer = VBoxContainer.new()
		new_menu.name = region
		new_menu_lines.name = region
		new_menu.title = region
		new_menu.folded = true
		Grid.add_child(new_menu)
		new_menu.add_child(new_menu_lines)
		RegionCheckMenus.append(new_menu_lines)
		for entry in Global.REGION_LIST[region]:
			var nested_checkbox : CheckBox = CheckBox.new()
			nested_checkbox.name = entry
			nested_checkbox.text = entry
			nested_checkbox.pressed.connect(_on_regions_changed)
			nested_checkbox.button_pressed = true
			new_menu_lines.add_child(nested_checkbox)
#			NestedCheckBoxes.append(new_checkbox)

func update_global_player_data() -> void:
	for big_region in RegionCheckBoxes:
		Global.selected_regions_big[big_region.name] = big_region.button_pressed
	for small_region_menu in RegionCheckMenus:
		for small_region in small_region_menu.get_children():
			Global.selected_regions_small[small_region.name] = small_region.button_pressed

func _on_regions_changed() -> void:
	update_global_player_data()
	regions_changed.emit(get_active_regions())
