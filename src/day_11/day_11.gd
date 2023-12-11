extends Node2D


@onready var tilemap: TileMap = $TileMap
const tilemap_layer_starfield := 0
const tilemap_layer_galaxies := 1


var empty_rows := {}
var empty_columns := {}


func _ready() -> void:

	# Have to connect these here because connecting them via the UI binds a node path relative from
	# the button, not the script.

	$"CanvasLayer/VBoxContainer/HBoxContainer4/CalculateAllDistancesWith2×ExpansionButton".pressed.connect(calculate_all_distances_with_expansion.bind(2, $"CanvasLayer/VBoxContainer/HBoxContainer4/SumOfAllDistancesWith2×ExpansionLabel"))
	$"CanvasLayer/VBoxContainer/HBoxContainer5/CalculateAllDistancesWith1,000,000×ExpansionButton".pressed.connect(calculate_all_distances_with_expansion.bind(1_000_000, $"CanvasLayer/VBoxContainer/HBoxContainer5/SumOfAllDistancesWith1,000,000×ExpansionLabel"))


func load_and_repopulate_tilemap(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:

	# Clear previous data

	tilemap.clear()
	$"CanvasLayer/VBoxContainer/HBoxContainer4/SumOfAllDistancesWith2×ExpansionLabel".text = "Not Yet Calculated"
	$"CanvasLayer/VBoxContainer/HBoxContainer5/SumOfAllDistancesWith1,000,000×ExpansionLabel".text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer6/NumEmptyRows.text = "n/a"
	$CanvasLayer/VBoxContainer/HBoxContainer7/NumEmptyColumns.text = "n/a"
	$CanvasLayer/VBoxContainer/HBoxContainer6/EmptyRows.text = "n/a"
	$CanvasLayer/VBoxContainer/HBoxContainer7/EmptyColumns.text = "n/a"

	empty_rows = {}
	empty_columns = {}

	for child: Node in $Lines.get_children():
		child.queue_free()


	# Populate

	var lines := input.split("\n", false)

	for y: int in lines.size():
		for x: int in lines[y].length():
			var character := lines[y][x]

			var starfield_atlas_coords := get_random_starfield_atlas_coords()
			tilemap.set_cell(tilemap_layer_starfield, Vector2i(x, y), 1, starfield_atlas_coords)

			if character == "#":
				var atlas_coords := get_random_galaxy_atlas_coords()
				tilemap.set_cell(tilemap_layer_galaxies, Vector2i(x, y), 1, atlas_coords)

	var tilemap_pos := tilemap.get_used_rect().position
	var tilemap_size := tilemap.get_used_rect().size

	# Determine which rows/columns are empty
	for x: int in range(tilemap_pos.x, tilemap_pos.x + tilemap_size.x):
		if not does_column_have_galaxies(x):
			empty_columns[x] = true

	for y: int in range(tilemap_pos.y, tilemap_pos.y + tilemap_size.y):
		if not does_row_have_galaxies(y):
			empty_rows[y] = true

	$CanvasLayer/VBoxContainer/HBoxContainer6/NumEmptyRows.text = str(empty_rows.size())
	$CanvasLayer/VBoxContainer/HBoxContainer7/NumEmptyColumns.text = str(empty_columns.size())

	$CanvasLayer/VBoxContainer/HBoxContainer6/EmptyRows.text = str(empty_rows.keys())
	$CanvasLayer/VBoxContainer/HBoxContainer7/EmptyColumns.text = str(empty_columns.keys())


func get_random_starfield_atlas_coords() -> Vector2i:
	return Vector2i(randi_range(0, 6), randi_range(0, 7))


func get_random_galaxy_atlas_coords() -> Vector2i:
	return Vector2i(7, randi_range(0, 7))


func calculate_all_distances_with_expansion(expansion_factor: int, result_label: Label) -> void:

	for child: Node in $Lines.get_children():
		child.queue_free()

	var galaxies: Array[Vector2i] = []

	var tilemap_pos := tilemap.get_used_rect().position
	var tilemap_size := tilemap.get_used_rect().size

	for x: int in range(tilemap_pos.x, tilemap_pos.x + tilemap_size.x):
		for y: int in range(tilemap_pos.y, tilemap_pos.y + tilemap_size.y):
			var galaxy_cell_data := tilemap.get_cell_tile_data(tilemap_layer_galaxies, Vector2i(x, y))
			if galaxy_cell_data != null:
				galaxies.push_back(Vector2i(x, y))

	var running_total := 0



	for galaxy_a: Vector2i in galaxies:
		var galaxy_a_idx := galaxy_a.x + (galaxy_a.y * tilemap_size.x)

		for galaxy_b: Vector2i in galaxies:
			var galaxy_b_idx := galaxy_b.x + (galaxy_b.y * tilemap_size.x)

			if galaxy_b_idx > galaxy_a_idx:
				# Add a visual line
				#var line_2d := Line2D.new()
				#line_2d.add_point((Vector2(galaxy_a) + Vector2(0.5, 0.5)) * tilemap.scale.x * tilemap.tile_set.tile_size.x)
				#line_2d.add_point((Vector2(galaxy_b) + Vector2(0.5, 0.5)) * tilemap.scale.x * tilemap.tile_set.tile_size.x)
				#line_2d.antialiased = true
				#line_2d.width = 2
				#line_2d.default_color = Color(1, 1, 1, 0.1)
				#$Lines.add_child(line_2d)

				# Calculate the distance
				var min_x := mini(galaxy_a.x, galaxy_b.x)
				var max_x := maxi(galaxy_a.x, galaxy_b.x)

				for x in range(min_x, max_x):
					if x in empty_columns:
						running_total += expansion_factor
					else:
						running_total += 1


				var min_y := mini(galaxy_a.y, galaxy_b.y)
				var max_y := maxi(galaxy_a.y, galaxy_b.y)

				for y in range(min_y, max_y):
					if y in empty_rows:
						running_total += expansion_factor
					else:
						running_total += 1

	result_label.text = str(running_total)


func does_column_have_galaxies(column: int) -> bool:
	for row: int in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y):
		var galaxy_cell_data := tilemap.get_cell_tile_data(tilemap_layer_galaxies, Vector2i(column, row))
		if galaxy_cell_data != null:
			return true

	return false


func does_row_have_galaxies(row: int) -> bool:
	for column: int in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x):
		var galaxy_cell_data := tilemap.get_cell_tile_data(tilemap_layer_galaxies, Vector2i(column, row))
		if galaxy_cell_data != null:
			return true

	return false


func _on_copy_part_1_result_pressed() -> void:
	DisplayServer.clipboard_set($"CanvasLayer/VBoxContainer/HBoxContainer4/SumOfAllDistancesWith2×ExpansionLabel".text)


func _on_copy_part_2_result_pressed() -> void:
	DisplayServer.clipboard_set($"CanvasLayer/VBoxContainer/HBoxContainer5/SumOfAllDistancesWith1,000,000×ExpansionLabel".text)
