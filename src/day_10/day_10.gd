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
const side_indicator_layer := 0
const start_layer := 1
const water_layer := 2
const pipes_layer := 3
const visitor_layer := 4

@onready var pipe_circumference_value_label := $CanvasLayer/VBoxContainer/HBoxContainer2/PipeCircumferenceValue
@onready var purple_tiles_count_label := $CanvasLayer/VBoxContainer/HBoxContainer3/PurpleTilesCount
@onready var orange_tiles_count_label := $CanvasLayer/VBoxContainer/HBoxContainer3/OrangeTilesCount

enum SimulationMode {
	none,
	trace_pipe_loop,
	flood_fill_sides,
}

var starting_pos: Vector2i
var previous_pos := Vector2i(-1, -1)
var current_pos: Vector2i
var simulation_mode := SimulationMode.none
var pipe_circumference := 0:
	set(value):
		pipe_circumference = value
		if pipe_circumference_value_label != null:
			pipe_circumference_value_label.text = str(pipe_circumference)


# Side A is whatever is to the left while moving up
var side_a_tiles := {}

# Side B is whatever is to the right while moving up
var side_b_tiles := {}

var visited_during_flood_fill := {}


const step_duration := 0.001
var time_since_last_step := 0.0


func _process(delta: float) -> void:

	if simulation_mode == SimulationMode.trace_pipe_loop:
		time_since_last_step += delta

		while time_since_last_step > step_duration:
			time_since_last_step -= step_duration
			current_pos = get_unfilled_neighbour(current_pos)

			if current_pos == Vector2i(-1, -1):
				simulation_mode = SimulationMode.none
				$CanvasLayer/VBoxContainer/HBoxContainer3/FloodFilleSidesButton.disabled = false
			else:
				tilemap.set_cell(
					water_layer,
					current_pos,
					2,
					tilemap.get_cell_atlas_coords(pipes_layer, current_pos) + pipe_to_water_atlas_coords_offset,
				)
				pipe_circumference += 1


	elif simulation_mode == SimulationMode.flood_fill_sides:
		time_since_last_step += delta

		while time_since_last_step > step_duration:
			time_since_last_step -= step_duration

			if current_pos not in visited_during_flood_fill:
				visited_during_flood_fill[current_pos] = true
				continue

			previous_pos = current_pos
			current_pos = get_next_filled_neighbour(current_pos)

			if current_pos == Vector2i(-1, -1):
				simulation_mode = SimulationMode.none
				return

			tilemap.set_cell(visitor_layer, current_pos, 2, Vector2i(3, 2))
			tilemap.set_cell(visitor_layer, previous_pos, 2, Vector2(-1, -1))

			visited_during_flood_fill[current_pos] = true

			var side_a_neighbours: Array[Vector2i]
			var side_b_neighbours: Array[Vector2i]

			var atlas_coords := tilemap.get_cell_atlas_coords(pipes_layer, current_pos)
			var direction := current_pos - previous_pos

			match [direction, atlas_coords]:
				# Went up
				[Vector2i.UP, pipe_v]:
					side_a_neighbours = [current_pos + Vector2i.LEFT]
					side_b_neighbours = [current_pos + Vector2i.RIGHT]

				[Vector2i.UP, pipe_se]:
					side_a_neighbours = [current_pos + Vector2i.LEFT, current_pos + Vector2i.UP]
					side_b_neighbours = []

				[Vector2i.UP, pipe_sw]:
					side_a_neighbours = []
					side_b_neighbours = [current_pos + Vector2i.RIGHT, current_pos + Vector2i.UP]

				# Went right
				[Vector2i.RIGHT, pipe_h]:
					side_a_neighbours = [current_pos + Vector2i.UP]
					side_b_neighbours = [current_pos + Vector2i.DOWN]

				[Vector2i.RIGHT, pipe_nw]:
					side_a_neighbours = []
					side_b_neighbours = [current_pos + Vector2i.RIGHT, current_pos + Vector2i.DOWN]

				[Vector2i.RIGHT, pipe_sw]:
					side_a_neighbours = [current_pos + Vector2i.RIGHT, current_pos + Vector2i.UP]
					side_b_neighbours = []

				# Went down
				[Vector2i.DOWN, pipe_v]:
					side_a_neighbours = [current_pos + Vector2i.RIGHT]
					side_b_neighbours = [current_pos + Vector2i.LEFT]

				[Vector2i.DOWN, pipe_ne]:
					side_a_neighbours = []
					side_b_neighbours = [current_pos + Vector2i.LEFT, current_pos + Vector2i.DOWN]

				[Vector2i.DOWN, pipe_nw]:
					side_a_neighbours = [current_pos + Vector2i.RIGHT, current_pos + Vector2i.DOWN]
					side_b_neighbours = []

				# Went left
				[Vector2i.LEFT, pipe_h]:
					side_a_neighbours = [current_pos + Vector2i.DOWN]
					side_b_neighbours = [current_pos + Vector2i.UP]

				[Vector2i.LEFT, pipe_ne]:
					side_a_neighbours = [current_pos + Vector2i.LEFT, current_pos + Vector2i.DOWN]
					side_b_neighbours = []

				[Vector2i.LEFT, pipe_se]:
					side_a_neighbours = []
					side_b_neighbours = [current_pos + Vector2i.LEFT, current_pos + Vector2i.UP]

				# Uh-oh!
				_:
					printerr("Unexpected direction/pipe combo: direction = %s, pipe atlas coords = %s" % [direction, atlas_coords])


			for side_a_neighbour: Vector2i in side_a_neighbours:
				flood_fill(side_a_neighbour, Vector2i(3, 0), side_a_tiles)

			for side_b_neighbour: Vector2i in side_b_neighbours:
				flood_fill(side_b_neighbour, Vector2i(3, 1), side_b_tiles)


			purple_tiles_count_label.text = str(side_a_tiles.size())
			orange_tiles_count_label.text = str(side_b_tiles.size())


# Return any neighbour that hasn't yet been filled with water
func get_unfilled_neighbour(pos: Vector2i) -> Vector2i:
	return get_neighbour(pos, false, {})


func get_next_filled_neighbour(pos: Vector2i) -> Vector2i:
	return get_neighbour(pos, true, visited_during_flood_fill)


func get_neighbour(pos: Vector2i, filled: bool, do_not_consider: Dictionary) -> Vector2i:
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
			var neighbour_is_filled := (
				tilemap.get_cell_tile_data(water_layer, neighbour_coords) != null or
				tilemap.get_cell_tile_data(start_layer, neighbour_coords) != null
			)

			if (
				neighbour_tile_data != null and
				neighbour_atlas_coords in neighbour_info["valid_atlas_coords"] and
				(
					(filled and neighbour_is_filled) or
					(not filled and not neighbour_is_filled)
				) and
				neighbour_coords not in do_not_consider
			):
				return neighbour_coords

	return Vector2i(-1, -1)



func flood_fill(starting_tile_coords: Vector2i, highlight_tile_atlas_coords: Vector2i, already_visited: Dictionary) -> void:

	var to_visit: Array[Vector2i] = [starting_tile_coords]

	while not to_visit.is_empty():
		var tile_coords: Vector2i = to_visit.pop_front()

		if (
			tilemap.get_cell_tile_data(water_layer, tile_coords) == null and
			tilemap.get_cell_tile_data(start_layer, tile_coords) == null and
			tile_coords not in already_visited and
			tilemap.get_used_rect().has_point(tile_coords)
		):
			already_visited[tile_coords] = true
			tilemap.set_cell(side_indicator_layer, tile_coords, 2, highlight_tile_atlas_coords)
			to_visit.append_array(get_surrounding_cells_with_corners(tile_coords))


func get_surrounding_cells_with_corners(pos: Vector2i) -> Array[Vector2i]:
	return  [
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_TOP_SIDE),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_LEFT_SIDE),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
		tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER),
	]


func load_and_populate_from_file(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:

	simulation_mode = SimulationMode.none
	tilemap.clear()
	pipe_circumference = 0
	pipe_circumference_value_label.text = "Not yet calculated"
	purple_tiles_count_label.text = "Not yet calculated"
	orange_tiles_count_label.text = "Not yet calculated"
	side_a_tiles = {}
	side_b_tiles = {}
	visited_during_flood_fill = {}
	$CanvasLayer/VBoxContainer/HBoxContainer2/TracePipeLoopButton.disabled = false
	$CanvasLayer/VBoxContainer/HBoxContainer3/FloodFilleSidesButton.disabled = true

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


func start_trace_pipe_loop() -> void:
	simulation_mode = SimulationMode.trace_pipe_loop
	$CanvasLayer/VBoxContainer/HBoxContainer2/TracePipeLoopButton.disabled = true
	$CanvasLayer/VBoxContainer/HBoxContainer3/FloodFilleSidesButton.disabled = true
	current_pos = starting_pos
	previous_pos = Vector2i(-1, -1)


func start_flood_fill_sides() -> void:
	simulation_mode = SimulationMode.flood_fill_sides
	$CanvasLayer/VBoxContainer/HBoxContainer2/TracePipeLoopButton.disabled = true
	$CanvasLayer/VBoxContainer/HBoxContainer3/FloodFilleSidesButton.disabled = true
	current_pos = starting_pos
	previous_pos = Vector2i(-1, -1)
