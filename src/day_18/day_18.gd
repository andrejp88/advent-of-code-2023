extends Node2D


@onready var tilemap: TileMap = $TileMap


func load_and_repopulate(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	repopulate(input)


func repopulate(input: String) -> void:
	tilemap.clear()
	$CanvasLayer/VBoxContainer/HBoxContainer2/LagoonVolumeLabel.text = "Not Yet Calculated"

	# Carve out the lagoon edges
	var initial_turtle_pos := Vector2i(0, 0)
	var turtle_pos := initial_turtle_pos

	for line: String in input.split("\n", false):
		var line_parts := line.split(" ", false)
		var direction := line_parts[0]
		var distance := int(line_parts[1])

		match direction:
			"U":
				for y: int in distance:
					turtle_pos.y -= 1
					tilemap.set_cell(0, turtle_pos, 0, Vector2i(2, 1))

			"D":
				for y: int in distance:
					turtle_pos.y += 1
					tilemap.set_cell(0, turtle_pos, 0, Vector2i(2, 1))

			"L":
				for x: int in distance:
					turtle_pos.x -= 1
					tilemap.set_cell(0, turtle_pos, 0, Vector2i(2, 1))

			"R":
				for x: int in distance:
					turtle_pos.x += 1
					tilemap.set_cell(0, turtle_pos, 0, Vector2i(2, 1))



func flood_fill_center() -> void:
	# First find a tile that is definitely inside the outline
	# Start at the middle of th left edge and follow the x axis until a
	# non-filled tile is reached. The only way this can fail is if the turtle
	# reverses leaving a 1-block nub, but I don't think it does.
	var rect := tilemap.get_used_rect()

	var flood_source_x := rect.position.x
	@warning_ignore("integer_division")
	var flood_source_y := rect.position.y + rect.size.y / 2

	var previous_is_filled := tilemap.get_cell_tile_data(0, Vector2i(0, flood_source_y)) != null

	while true:
		var current_is_filled := tilemap.get_cell_tile_data(0, Vector2i(flood_source_x, flood_source_y)) != null

		tilemap.set_cell(1, Vector2i(flood_source_x, flood_source_y), 0, Vector2i(0, 3))
		await get_tree().process_frame
		tilemap.set_cell(1, Vector2i(flood_source_x, flood_source_y), -1)

		if previous_is_filled and not current_is_filled:
			break

		previous_is_filled = current_is_filled
		flood_source_x += 1

	var draw_interval := 100
	var iterations_since_draw := 0

	var flood_fill_queue: Array[Vector2i] = [Vector2i(flood_source_x, flood_source_y)]

	while not flood_fill_queue.is_empty():
		var to_fill: Vector2i = flood_fill_queue.pop_back()

		tilemap.set_cell(0, to_fill, 0, Vector2i(2, 1))

		var neighbours: Array[Vector2i] = [
			to_fill + Vector2i.UP,
			to_fill + Vector2i.DOWN,
			to_fill + Vector2i.LEFT,
			to_fill + Vector2i.RIGHT
		]

		neighbours.assign(neighbours.filter(
			func(neighbour: Vector2i) -> bool:
				return tilemap.get_cell_tile_data(0, neighbour) == null and neighbour not in flood_fill_queue,
		))

		flood_fill_queue.append_array(neighbours)

		iterations_since_draw += 1
		if iterations_since_draw >= draw_interval:
			iterations_since_draw -= draw_interval
			await get_tree().process_frame

	$CanvasLayer/VBoxContainer/HBoxContainer2/LagoonVolumeLabel.text = "%d m³" % [tilemap.get_used_cells(0).size()]
