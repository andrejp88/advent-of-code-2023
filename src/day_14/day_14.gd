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
				move_round_rock_up(Vector2i(x, y),)

	var total_load_factor := 0

	for y: int in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().size.y):
		var load_factor_at_row := tilemap.get_used_rect().size.y - y
		for x: int in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().size.x):
			if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, y)) == atlas_coords_round_rock:
				total_load_factor += load_factor_at_row

	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnNorthEdgeLabel.text = str(total_load_factor)


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

	var new_pos := Vector2i(pos.x, tilemap.get_used_rect().position.y)
	tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
