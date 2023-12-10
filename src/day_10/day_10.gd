extends Node2D


const pipe_v := Vector2i(2, 0)
const pipe_h := Vector2i(2, 1)
const pipe_se := Vector2i(0, 0)
const pipe_sw := Vector2i(1, 0)
const pipe_nw := Vector2i(1, 1)
const pipe_ne := Vector2i(0, 1)

const pipe_to_water_atlas_coords_offset := Vector2i(0, 2)

const water_v := pipe_v + pipe_to_water_atlas_coords_offset
const water_h := pipe_h + pipe_to_water_atlas_coords_offset
const water_se := pipe_se + pipe_to_water_atlas_coords_offset
const water_sw := pipe_sw + pipe_to_water_atlas_coords_offset
const water_nw := pipe_nw + pipe_to_water_atlas_coords_offset
const water_ne := pipe_ne + pipe_to_water_atlas_coords_offset

const ascii_to_pipe_atlas_coords := {
	"-": pipe_h,
	"|": pipe_v,
	"F": pipe_se,
	"7": pipe_sw,
	"J": pipe_nw,
	"L": pipe_ne,
}


@onready var tilemap: TileMap = $TileMap
const start_layer := 0
const water_layer := 1
const pipes_layer := 2

@onready var pipe_circumference_value_label := $CanvasLayer/VBoxContainer/HBoxContainer2/PipeCircumferenceValue

var starting_pos: Vector2i
var current_pos: Vector2i
var is_simulating := false
var pipe_circumference := 0:
	set(value):
		pipe_circumference = value
		if pipe_circumference_value_label != null:
			pipe_circumference_value_label.text = str(pipe_circumference)


const step_duration := 0.001
var time_since_last_step := 0.0


func _process(delta: float) -> void:
	if is_simulating:
		time_since_last_step += delta

		while time_since_last_step > step_duration:
			time_since_last_step -= step_duration
			current_pos = get_unfilled_neighbour(current_pos)

			if current_pos == Vector2i(-1, -1):
				is_simulating = false
			else:
				tilemap.set_cell(
					water_layer,
					current_pos,
					2,
					tilemap.get_cell_atlas_coords(pipes_layer, current_pos) + pipe_to_water_atlas_coords_offset,
				)
				pipe_circumference += 1


# Return any neighbour that hasn't yet been filled with water
func get_unfilled_neighbour(pos: Vector2i) -> Vector2i:
	const neighbour_data := [
		{ "direction": Vector2i.UP, "valid_atlas_coords": [pipe_v, pipe_se, pipe_sw] },
		{ "direction": Vector2i.DOWN, "valid_atlas_coords": [pipe_v, pipe_ne, pipe_nw] },
		{ "direction": Vector2i.LEFT, "valid_atlas_coords": [pipe_h, pipe_se, pipe_ne] },
		{ "direction": Vector2i.RIGHT, "valid_atlas_coords": [pipe_h, pipe_sw, pipe_nw] },
	]

	var actual_neighbours: Array[Vector2i] = []

	match tilemap.get_cell_atlas_coords(pipes_layer, pos):
		pipe_h:
			actual_neighbours = [Vector2i.LEFT, Vector2i.RIGHT]
		pipe_v:
			actual_neighbours = [Vector2i.UP, Vector2i.DOWN]
		pipe_se:
			actual_neighbours = [Vector2i.RIGHT, Vector2i.DOWN]
		pipe_sw:
			actual_neighbours = [Vector2i.LEFT, Vector2i.DOWN]
		pipe_nw:
			actual_neighbours = [Vector2i.UP, Vector2i.LEFT]
		pipe_ne:
			actual_neighbours = [Vector2i.UP, Vector2i.RIGHT]

	for neighbour_info: Dictionary in neighbour_data:
		if neighbour_info["direction"] in actual_neighbours:
			var neighbour_coords: Vector2i = pos + neighbour_info["direction"]
			var neighbour_tile_data := tilemap.get_cell_tile_data(pipes_layer, neighbour_coords)
			var neighbour_atlas_coords := tilemap.get_cell_atlas_coords(pipes_layer, neighbour_coords)
			var neighbour_is_unfilled := (
				tilemap.get_cell_tile_data(water_layer, neighbour_coords) == null and
				tilemap.get_cell_tile_data(start_layer, neighbour_coords) == null
			)

			if neighbour_tile_data != null and neighbour_atlas_coords in neighbour_info["valid_atlas_coords"] and neighbour_is_unfilled:
				return neighbour_coords

	return Vector2i(-1, -1)


func load_and_populate_from_file(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:

	tilemap.clear()
	pipe_circumference = 0
	pipe_circumference_value_label.text = "Not yet calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/PlayButton.disabled = false

	var lines := input.split("\n", false)

	for y: int in lines.size():
		var line := lines[y]
		for x: int in line.length():
			var character := line[x]
			match character:
				"S":
					starting_pos = Vector2i(x, y)
				".":
					pass
				_:
					tilemap.set_cell(pipes_layer, Vector2i(x, y), 2, ascii_to_pipe_atlas_coords[character])


	# Figure out what kind of pipe starting_pos should be.
	# The problem description says that we can tell based on the adjacent pipes.
	var up_neighbour := tilemap.get_cell_atlas_coords(pipes_layer, starting_pos + Vector2i.UP)
	var down_neighbour := tilemap.get_cell_atlas_coords(pipes_layer, starting_pos + Vector2i.DOWN)
	var left_neighbour := tilemap.get_cell_atlas_coords(pipes_layer, starting_pos + Vector2i.LEFT)
	var right_neighbour := tilemap.get_cell_atlas_coords(pipes_layer, starting_pos + Vector2i.RIGHT)

	var starting_pos_atlas_coords := Vector2i(-1, -1)

	match [up_neighbour, down_neighbour, left_neighbour, right_neighbour]:

		[var up, var down, _, _] when up in [pipe_v, pipe_se, pipe_sw] and down in [pipe_v, pipe_ne, pipe_nw]:
			starting_pos_atlas_coords = pipe_v

		[var up, _, var left, _] when up in [pipe_v, pipe_se, pipe_sw] and left in [pipe_h, pipe_se, pipe_ne]:
			starting_pos_atlas_coords = pipe_nw

		[var up, _, _, var right] when up in [pipe_v, pipe_se, pipe_sw] and right in [pipe_h, pipe_sw, pipe_nw]:
			starting_pos_atlas_coords = pipe_ne

		[_, var down, var left, _] when down in [pipe_v, pipe_ne, pipe_nw] and left in [pipe_h, pipe_se, pipe_ne]:
			starting_pos_atlas_coords = pipe_sw

		[_, var down, _, var right] when down in [pipe_v, pipe_ne, pipe_nw] and right in [pipe_h, pipe_sw, pipe_nw]:
			starting_pos_atlas_coords = pipe_se

		[_, _, var left, var right] when left in [pipe_h, pipe_se, pipe_ne] and right in [pipe_h, pipe_sw, pipe_nw]:
			starting_pos_atlas_coords = pipe_h

		_:
			printerr("Starting position does not connect to two neighbours. starting_pos = ", starting_pos, ", neighbours = ", [up_neighbour, down_neighbour, left_neighbour, right_neighbour])


	tilemap.set_cell(pipes_layer, starting_pos, 2, starting_pos_atlas_coords)
	tilemap.set_cell(start_layer, starting_pos, 2, starting_pos_atlas_coords + pipe_to_water_atlas_coords_offset)


func play() -> void:
	is_simulating = true
	$CanvasLayer/VBoxContainer/HBoxContainer2/PlayButton.disabled = true
	current_pos = starting_pos
