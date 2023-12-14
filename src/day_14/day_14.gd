extends Node2D


@onready var tilemap: TileMap = $TileMap


const tilemap_layer_ground := 0
const tilemap_layer_rocks := 1

const atlas_coords_ground := Vector2i(0, 0)
const atlas_coords_square_rock := Vector2i(1, 0)
const atlas_coords_round_rock := Vector2i(0, 1)


func load_and_populate(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()
	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:
	tilemap.clear()
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnNorthEdgeLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnEastEdgeLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnSouthEdgeLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnWestEdgeLabel.text = "Not Yet Calculated"

	var lines := input.split("\n", false)

	for y: int in lines.size():
		for x: int in lines[y].length():
			tilemap.set_cell(tilemap_layer_ground, Vector2i(x, y), 0, atlas_coords_ground)

			if lines[y][x] == "#":
				tilemap.set_cell(tilemap_layer_rocks, Vector2i(x, y), 0, atlas_coords_square_rock)

			elif lines[y][x] == "O":
				tilemap.set_cell(tilemap_layer_rocks, Vector2i(x, y), 0, atlas_coords_round_rock)


func tilt_platform_up() -> void:
	for x: int in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x):
		for y: int in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().size.y):
			if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, y)) == atlas_coords_round_rock:
				move_round_rock_up(Vector2i(x, y))

	calculate_north_load()
	calculate_east_load()
	calculate_south_load()
	calculate_west_load()


func move_round_rock_up(pos: Vector2i) -> void:
	if pos.y == tilemap.get_used_rect().position.y:
		return

	for y: int in range(pos.y - 1, tilemap.get_used_rect().position.y - 1, -1):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(pos.x, y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(pos.x, y + 1)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			return

	var next_to_wall_pos := Vector2i(pos.x, tilemap.get_used_rect().position.y)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))


func calculate_north_load() -> void:
	var total_load_factor := 0

	for coords: Vector2i in tilemap.get_used_cells(tilemap_layer_rocks):
		if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, coords) == atlas_coords_round_rock:
			total_load_factor += tilemap.get_used_rect().size.y - (coords.y - tilemap.get_used_rect().position.y)

	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnNorthEdgeLabel.text = str(total_load_factor)


func tilt_platform_right() -> void:
	for y: int in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().size.y):
		for x: int in range(tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x + -1, tilemap.get_used_rect().position.x - 1, -1):
			if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, y)) == atlas_coords_round_rock:
				move_round_rock_right(Vector2i(x, y))

	calculate_north_load()
	calculate_east_load()
	calculate_south_load()
	calculate_west_load()


func move_round_rock_right(pos: Vector2i) -> void:
	if pos.x == tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x - 1:
		return

	for x: int in range(pos.x + 1, tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, pos.y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(x - 1, pos.y)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			return

	var next_to_wall_pos := Vector2i(tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x - 1, pos.y)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))


func calculate_east_load() -> void:
	var total_load_factor := 0

	for coords: Vector2i in tilemap.get_used_cells(tilemap_layer_rocks):
		if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, coords) == atlas_coords_round_rock:
			total_load_factor += coords.x - tilemap.get_used_rect().position.x + 1

	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnEastEdgeLabel.text = str(total_load_factor)


func tilt_platform_down() -> void:
	for x: int in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x):
		for y: int in range(tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y - 1, tilemap.get_used_rect().position.y - 1, -1):
			if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, y)) == atlas_coords_round_rock:
				move_round_rock_down(Vector2i(x, y))

	calculate_north_load()
	calculate_east_load()
	calculate_south_load()
	calculate_west_load()


func move_round_rock_down(pos: Vector2i) -> void:
	if pos.y == tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y - 1:
		return

	for y: int in range(pos.y + 1, tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(pos.x, y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(pos.x, y - 1)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			return

	var next_to_wall_pos := Vector2i(pos.x, tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y - 1)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))


func calculate_south_load() -> void:
	var total_load_factor := 0

	for coords: Vector2i in tilemap.get_used_cells(tilemap_layer_rocks):
		if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, coords) == atlas_coords_round_rock:
			total_load_factor += coords.y - tilemap.get_used_rect().position.y + 1

	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnSouthEdgeLabel.text = str(total_load_factor)


func tilt_platform_left() -> void:
	for y: int in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().size.y):
		for x: int in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x):
			if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, y)) == atlas_coords_round_rock:
				move_round_rock_left(Vector2i(x, y))

	calculate_north_load()
	calculate_east_load()
	calculate_south_load()
	calculate_west_load()


func move_round_rock_left(pos: Vector2i) -> void:
	if pos.x == tilemap.get_used_rect().position.x:
		return

	for x: int in range(pos.x - 1, tilemap.get_used_rect().position.x - 1, -1):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, pos.y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(x + 1, pos.y)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			return

	var next_to_wall_pos := Vector2i(tilemap.get_used_rect().position.x, pos.y)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))


func calculate_west_load() -> void:
	var total_load_factor := 0

	for coords: Vector2i in tilemap.get_used_cells(tilemap_layer_rocks):
		if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, coords) == atlas_coords_round_rock:
			total_load_factor += tilemap.get_used_rect().size.x - (coords.x - tilemap.get_used_rect().position.x)

	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnWestEdgeLabel.text = str(total_load_factor)


func perform_spin_cycle() -> void:
	tilt_platform_up()
	tilt_platform_left()
	tilt_platform_down()
	tilt_platform_right()


func simulate_billion_cycles() -> void:
	pass # Replace with function body.
