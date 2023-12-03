extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var camera: Camera2D = $Camera2D


func repopulate_tilemap(path: String) -> void:
	tilemap.clear()

	var fa := FileAccess.open(path, FileAccess.READ)
	var data := fa.get_as_text()
	fa.close()

	var lines := data.split("\n", false)

	for line_idx in range(lines.size()):
		var line := lines[line_idx]
		for character_idx in range(line.length()):
			var character := line[character_idx]
			if character != ".":
				tilemap.set_cell(1, Vector2(character_idx, line_idx), 1, get_atlas_coords(character))


func get_atlas_coords(character: String) -> Vector2:
	match character:
		"0": return Vector2(0, 0)
		"1": return Vector2(1, 0)
		"2": return Vector2(2, 0)
		"3": return Vector2(3, 0)
		"4": return Vector2(4, 0)
		"5": return Vector2(5, 0)
		"6": return Vector2(6, 0)
		"7": return Vector2(7, 0)
		"8": return Vector2(0, 1)
		"9": return Vector2(1, 1)
		"+": return Vector2(2, 1)
		"-": return Vector2(3, 1)
		"*": return Vector2(4, 1)
		"/": return Vector2(5, 1)
		"=": return Vector2(6, 1)
		"@": return Vector2(7, 1)
		"#": return Vector2(0, 2)
		"$": return Vector2(1, 2)
		"%": return Vector2(2, 2)
		"&": return Vector2(3, 2)
		_:
			printerr("Unexpected character: '", character, "'")
			return Vector2(7, 7)


func get_digit(tile_atlas_coords: Vector2i) -> int:
	if tile_atlas_coords.y == 0:
		return tile_atlas_coords.x
	elif tile_atlas_coords.y == 1 and tile_atlas_coords.x <= 1:
		return 8 + tile_atlas_coords.x
	else:
		return -100000


func highlight_all_numbers() -> void:
	for tile_coords: Vector2i in tilemap.get_used_cells(1):
		var tile_atlas_coords := tilemap.get_cell_atlas_coords(1, tile_coords)
		if is_number_cell(tile_atlas_coords):
			tilemap.set_cell(0, tile_coords, 1, Vector2(5, 7))


func highlight_part_numbers() -> void:
	for tile_coords: Vector2i in tilemap.get_used_cells(1):
		var tile_atlas_coords := tilemap.get_cell_atlas_coords(1, tile_coords)
		if is_symbol_cell(tile_atlas_coords):
			var already_visited := {tile_coords: true}
			var neighbours := get_surrounding_cells_with_corners(tile_coords)
			for neighbour: Vector2i in neighbours:
				if not (neighbour in already_visited):
					flood_fill(neighbour, Vector2(4, 7), already_visited)


func get_part_numbers() -> Array[int]:
	var part_numbers: Array[int] = []

	for tile_coords: Vector2i in tilemap.get_used_cells(0):
		var tile_atlas_coords_layer_0 := tilemap.get_cell_atlas_coords(0, tile_coords)
		var tile_atlas_coords_layer_1 := tilemap.get_cell_atlas_coords(1, tile_coords)

		if is_number_cell(tile_atlas_coords_layer_1) and tile_atlas_coords_layer_0 == Vector2i(4, 7):

			# If it's the left-most number cell, parse the number, else we have already parsed it probably
			var left_cell_coords := tile_coords - Vector2i(1, 0)
			var left_cell_atlas_coords := tilemap.get_cell_atlas_coords(1, left_cell_coords)
			var left_cell_data := tilemap.get_cell_tile_data(1, left_cell_coords)

			#if left_cell_data == null or not is_number_cell(left_cell_coords):
			if is_number_cell(left_cell_atlas_coords):
				continue

			var this_number := get_digit(tile_atlas_coords_layer_1)
			var i := 1

			while true:
				var next_tile_coords := tile_coords + Vector2i(i, 0)
				var next_tile_atlas_coords := tilemap.get_cell_atlas_coords(1, next_tile_coords)

				if not is_number_cell(next_tile_atlas_coords):
					break

				this_number *= 10
				this_number += get_digit(next_tile_atlas_coords)

				i += 1

			part_numbers.push_back(this_number)

	return part_numbers


func flood_fill(tile_coords: Vector2i, highlight_tile_atlas_coords: Vector2i, already_visited: Dictionary) -> void:

	var tile_atlas_coords := tilemap.get_cell_atlas_coords(1, tile_coords)
	already_visited[tile_coords] = true

	if is_number_cell(tile_atlas_coords):
		tilemap.set_cell(0, tile_coords, 1, highlight_tile_atlas_coords)

		for neighbour: Vector2i in get_horizontal_neighbours(tile_coords):
			if not (neighbour in already_visited):
				flood_fill(neighbour, highlight_tile_atlas_coords, already_visited)


func get_surrounding_cells_with_corners(tile_coords: Vector2i) -> Array[Vector2i]:
	return  [
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_SIDE),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER),
	]

func get_horizontal_neighbours(tile_coords: Vector2i) -> Array[Vector2i]:
	return  [
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_LEFT_SIDE),
		tilemap.get_neighbor_cell(tile_coords, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
	]


func is_number_cell(tile_atlas_coords: Vector2i) -> bool:
	return (
		tile_atlas_coords.y == 0 or
		(tile_atlas_coords.y == 1 and tile_atlas_coords.x <= 1)
	)


func is_symbol_cell(tile_atlas_coords: Vector2i) -> bool:
	return (
		(tile_atlas_coords.y == 1 and tile_atlas_coords.x >= 2) or
		(tile_atlas_coords.y == 2 and tile_atlas_coords.x <= 3)
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			camera.global_position -= (mouse_motion_event.relative) / camera.zoom.x

	elif event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton

		if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var zoom_factor := camera.zoom * 1.125
			if zoom_factor.x < 20.0:
				camera.zoom = zoom_factor
			if is_equal_approx(camera.zoom.x, 1.0):
				camera.zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var zoom_factor := camera.zoom / 1.125
			if zoom_factor.x > 1.0 / 20.0:
				camera.zoom = zoom_factor
			if is_equal_approx(camera.zoom.x, 1.0):
				camera.zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			if not mouse_button_event.pressed:
				camera.global_position = Vector2(roundf(camera.global_position.x), roundf(camera.global_position.y))


func _on_use_test_input_pressed() -> void:
	repopulate_tilemap("res://src/day_3/test_input.txt")


func _on_use_real_input_pressed() -> void:
	repopulate_tilemap("res://src/day_3/input.txt")


func _on_highlight_part_numbers_button_pressed() -> void:
	highlight_all_numbers()
	highlight_part_numbers()

	var part_numbers := get_part_numbers()
	$CanvasLayer/VBoxContainer/HBoxContainer2/NumPartNumbers.text = "Part Number Count: %d" % part_numbers.size()

	var part_number_sum := part_numbers.reduce(func(acc: int, e: int) -> int: return acc + e) as int
	$CanvasLayer/VBoxContainer/HBoxContainer2/PartNumberSum.text = "Part Number Sum: %d" % part_number_sum
