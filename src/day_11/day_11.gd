extends Node2D


@onready var tilemap: TileMap = $TileMap
const tilemap_layer_starfield := 0
const tilemap_layer_galaxies := 1


func load_and_repopulate_tilemap(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:

	tilemap.clear()
	$CanvasLayer/VBoxContainer/HBoxContainer3/SumOfAllDistanceLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/ExpandUniverseButton.disabled = false
	$CanvasLayer/VBoxContainer/HBoxContainer3/CalculateAllDistancesButton.disabled = true
	for child: Node in $Lines.get_children():
		child.queue_free()

	var lines := input.split("\n", false)

	for y: int in lines.size():
		for x: int in lines[y].length():
			var character := lines[y][x]

			var starfield_atlas_coords := get_random_starfield_atlas_coords()
			tilemap.set_cell(tilemap_layer_starfield, Vector2i(x, y), 1, starfield_atlas_coords)

			if character == "#":
				var atlas_coords := get_random_galaxy_atlas_coords()
				tilemap.set_cell(tilemap_layer_galaxies, Vector2i(x, y), 1, atlas_coords)


func get_random_starfield_atlas_coords() -> Vector2i:
	return Vector2i(randi_range(0, 6), randi_range(0, 7))


func get_random_galaxy_atlas_coords() -> Vector2i:
	return Vector2i(7, randi_range(0, 7))


func expand_universe() -> void:

	var initial_pos := tilemap.get_used_rect().position
	var initial_size := tilemap.get_used_rect().size

	# 1. add empty space between every row and column (even emptier than the intergalactic vacuum, what a concept)
	for x: int in range(initial_pos.x + initial_size.x - 1, initial_pos.x - 1, -1):
		for y: int in range(initial_pos.y + initial_size.y - 1, initial_pos.y - 1, -1):
			move_cell(Vector2i(x, y), Vector2i(x * 2, y * 2))


	# 2. Fill in extra columns where needed
	for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2, 2):
		var should_duplicate_column := true

		for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2, 2):
			var galaxy_cell_data := tilemap.get_cell_tile_data(tilemap_layer_galaxies, Vector2i(x, y))
			if galaxy_cell_data != null:
				should_duplicate_column = false

		if should_duplicate_column:
			for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2, 2):
				tilemap.set_cell(tilemap_layer_starfield, Vector2i(x + 1, y), 1, get_random_starfield_atlas_coords())


	# 3. Fill in extra rows where needed
	for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2, 2):
		var should_duplicate_row := true

		for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2, 2):
			var galaxy_cell_data := tilemap.get_cell_tile_data(tilemap_layer_galaxies, Vector2i(x, y))
			if galaxy_cell_data != null:
				should_duplicate_row = false

		if should_duplicate_row:
			for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2):                             # Don't skip starfields, make sure to visit already duplicated ones as well...
				var starfield_cell_data := tilemap.get_cell_tile_data(tilemap_layer_starfield, Vector2i(x, y))
				if starfield_cell_data != null:                                                                 # ...but only if it was actually duplicated.
					tilemap.set_cell(tilemap_layer_starfield, Vector2i(x, y + 1), 1, get_random_starfield_atlas_coords())


	# 4. Remove the emptier-than-empty columns
	for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2):

		var should_remove_this_column := true

		for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2):
			var starfield_cell_data := tilemap.get_cell_tile_data(tilemap_layer_starfield, Vector2i(x, y))
			if starfield_cell_data != null:
				should_remove_this_column = false
				break

		if should_remove_this_column:
			var next_non_empty_column := -1

			for candidate_x: int in range(x + 1, initial_pos.x + initial_size.x * 2):
				var is_column_populated := false

				for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2):
					var starfield_cell_data := tilemap.get_cell_tile_data(tilemap_layer_starfield, Vector2i(candidate_x, y))
					if starfield_cell_data != null:
						is_column_populated = true
						break

				if is_column_populated:
					next_non_empty_column = candidate_x
					break

			if next_non_empty_column == -1:
				break


			for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2):
				move_cell(Vector2i(next_non_empty_column, y), Vector2i(x, y))


	# 5. Remove the emptier-than-empty rows
	for y: int in range(initial_pos.y, initial_pos.y + initial_size.y * 2):

		var should_remove_this_row := true

		for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2):
			var starfield_cell_data := tilemap.get_cell_tile_data(tilemap_layer_starfield, Vector2i(x, y))
			if starfield_cell_data != null:
				should_remove_this_row = false
				break

		if should_remove_this_row:
			var next_non_empty_row := -1

			for candidate_y: int in range(y + 1, initial_pos.y + initial_size.y * 2):
				var is_column_populated := false

				for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2):
					var starfield_cell_data := tilemap.get_cell_tile_data(tilemap_layer_starfield, Vector2i(x, candidate_y))
					if starfield_cell_data != null:
						is_column_populated = true
						break

				if is_column_populated:
					next_non_empty_row = candidate_y
					break

			if next_non_empty_row == -1:
				break


			for x: int in range(initial_pos.x, initial_pos.x + initial_size.x * 2):
				move_cell(Vector2i(x, next_non_empty_row), Vector2i(x, y))


	# 6. Post-expansion work
	$CanvasLayer/VBoxContainer/HBoxContainer3/CalculateAllDistancesButton.disabled = false
	$CanvasLayer/VBoxContainer/HBoxContainer2/ExpandUniverseButton.disabled = true


func move_cell(from: Vector2i, to: Vector2i) -> void:
	var starfield_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_starfield, from)
	tilemap.set_cell(tilemap_layer_starfield, from, -1, Vector2i(-1, -1))
	tilemap.set_cell(tilemap_layer_starfield, to, 1, starfield_atlas_coords)

	var galaxy_cell_data := tilemap.get_cell_tile_data(tilemap_layer_galaxies, from)
	if galaxy_cell_data != null:
		var galaxy_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_galaxies, from)
		tilemap.set_cell(tilemap_layer_galaxies, from, -1, Vector2i(-1, -1))
		tilemap.set_cell(tilemap_layer_galaxies, to, 1, galaxy_atlas_coords)


func calculate_all_distances() -> void:

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
				var line_2d := Line2D.new()
				line_2d.add_point((Vector2(galaxy_a) + Vector2(0.5, 0.5)) * tilemap.scale.x * tilemap.tile_set.tile_size.x)
				line_2d.add_point((Vector2(galaxy_b) + Vector2(0.5, 0.5)) * tilemap.scale.x * tilemap.tile_set.tile_size.x)
				line_2d.antialiased = true
				line_2d.width = 2
				line_2d.default_color = Color(1, 1, 1, 0.1)
				$Lines.add_child(line_2d)

				# Calculate the distance
				running_total += absi(galaxy_a.x - galaxy_b.x) + absi(galaxy_a.y - galaxy_b.y)

	$CanvasLayer/VBoxContainer/HBoxContainer3/SumOfAllDistanceLabel.text = str(running_total)
