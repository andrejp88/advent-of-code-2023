extends Node2D


@onready var tilemap: TileMap = $TileMap


const tilemap_layer_ground := 0
const tilemap_layer_rocks := 1

const atlas_coords_ground := Vector2i(0, 0)
const atlas_coords_square_rock := Vector2i(1, 0)
const atlas_coords_round_rock := Vector2i(0, 1)

var max_cycles_remaining := 0
const seconds_per_cycle := 0.1
var time_since_last_cycle := 0.0

var fingerprint_history: Array[String] = []
var fingerprint_history_cache := {}


func _process(delta: float) -> void:
	if max_cycles_remaining > 0:
		time_since_last_cycle += delta
		while time_since_last_cycle > seconds_per_cycle:
			perform_spin_cycle()
			max_cycles_remaining -= 1
			time_since_last_cycle -= seconds_per_cycle
			$CanvasLayer/VBoxContainer/HBoxContainer3/SpinCyclesRemainingLabel.text = "Spin cycles remaining: %d" % [max_cycles_remaining]

			var last_fingerprint := fingerprint_history[fingerprint_history.size() - 1]
			if last_fingerprint in fingerprint_history_cache:
				max_cycles_remaining = 0

				var first_instance_idx := fingerprint_history.find(last_fingerprint)
				var last_instance_idx := fingerprint_history.size() - 1
				var period := last_instance_idx - first_instance_idx

				$CanvasLayer/VBoxContainer/HBoxContainer3/SpinCyclesRemainingLabel.text = "Found a repeating pattern of length %s, beginning at %s and ending just before %s" % [period, first_instance_idx, last_instance_idx]
				var billionth_fingerprint_index := (1_000_000_000 - first_instance_idx) % period + first_instance_idx
				var billionth_fingerprint_north_load: int = fingerprint_history_cache[fingerprint_history[billionth_fingerprint_index]]
				$CanvasLayer/VBoxContainer/HBoxContainer4/ResultLabel.text = "After 1 billion cycles, the load on the north wall will be %s" % [billionth_fingerprint_north_load]
				break

			else:
				fingerprint_history_cache[fingerprint_history[fingerprint_history.size() - 1]] = calculate_north_load()




func load_and_populate(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()
	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:
	await get_tree().process_frame

	tilemap.clear()
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnNorthEdgeLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnEastEdgeLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnSouthEdgeLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnWestEdgeLabel.text = "Not Yet Calculated"
	var rock_numbers_container := $RockNumbers/RockNumbersContainer
	$RockNumbers.remove_child(rock_numbers_container)
	rock_numbers_container.free()

	rock_numbers_container = Node2D.new()
	rock_numbers_container.name = "RockNumbersContainer"
	$RockNumbers.add_child(rock_numbers_container)

	var lines := input.split("\n", false)

	var rock_id := 0

	for y: int in lines.size():
		for x: int in lines[y].length():
			tilemap.set_cell(tilemap_layer_ground, Vector2i(x, y), 0, atlas_coords_ground)

			if lines[y][x] == "#":
				tilemap.set_cell(tilemap_layer_rocks, Vector2i(x, y), 0, atlas_coords_square_rock)

			elif lines[y][x] == "O":
				tilemap.set_cell(tilemap_layer_rocks, Vector2i(x, y), 0, atlas_coords_round_rock)
				var number_label := Label.new()
				number_label.name = str("%s,%s" % [x, y])
				number_label.theme = preload("res://src/monocraft_theme.tres")
				number_label.text = str(rock_id)
				rock_numbers_container.add_child(number_label)
				set_label_center_global_position_to_tile(number_label, Vector2i(x, y))
				rock_id += 1

	fingerprint_history.clear()
	fingerprint_history.append(get_layout_fingerprint())
	fingerprint_history_cache.clear()
	fingerprint_history_cache[fingerprint_history[fingerprint_history.size() - 1]] = calculate_north_load()


func set_label_center_global_position_to_tile(label: Label, pos: Vector2i) -> void:
	label.global_position = (
		Vector2(tilemap.tile_set.tile_size) * Vector2(pos) +
		Vector2(tilemap.tile_set.tile_size) / 2.0 -
		label.size / 2.0
	)


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

	var label := $RockNumbers/RockNumbersContainer.get_node("%s,%s" % [pos.x, pos.y])

	for y: int in range(pos.y - 1, tilemap.get_used_rect().position.y - 1, -1):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(pos.x, y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(pos.x, y + 1)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			set_label_center_global_position_to_tile(label, new_pos)
			label.name = "%s,%s" % [new_pos.x, new_pos.y]
			return

	var next_to_wall_pos := Vector2i(pos.x, tilemap.get_used_rect().position.y)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
	set_label_center_global_position_to_tile(label, next_to_wall_pos)
	label.name = "%s,%s" % [next_to_wall_pos.x, next_to_wall_pos.y]


func calculate_north_load() -> int:
	var total_load_factor := 0

	for coords: Vector2i in tilemap.get_used_cells(tilemap_layer_rocks):
		if tilemap.get_cell_atlas_coords(tilemap_layer_rocks, coords) == atlas_coords_round_rock:
			total_load_factor += tilemap.get_used_rect().size.y - (coords.y - tilemap.get_used_rect().position.y)

	$CanvasLayer/VBoxContainer/HBoxContainer2/LoadOnNorthEdgeLabel.text = str(total_load_factor)

	return total_load_factor


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

	var label := $RockNumbers/RockNumbersContainer.get_node("%s,%s" % [pos.x, pos.y])

	for x: int in range(pos.x + 1, tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, pos.y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(x - 1, pos.y)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			set_label_center_global_position_to_tile(label, new_pos)
			label.name = "%s,%s" % [new_pos.x, new_pos.y]
			return

	var next_to_wall_pos := Vector2i(tilemap.get_used_rect().position.x + tilemap.get_used_rect().size.x - 1, pos.y)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
	set_label_center_global_position_to_tile(label, next_to_wall_pos)
	label.name = "%s,%s" % [next_to_wall_pos.x, next_to_wall_pos.y]


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

	var label := $RockNumbers/RockNumbersContainer.get_node("%s,%s" % [pos.x, pos.y])

	for y: int in range(pos.y + 1, tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(pos.x, y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(pos.x, y - 1)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			set_label_center_global_position_to_tile(label, new_pos)
			label.name = "%s,%s" % [new_pos.x, new_pos.y]
			return

	var next_to_wall_pos := Vector2i(pos.x, tilemap.get_used_rect().position.y + tilemap.get_used_rect().size.y - 1)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
	set_label_center_global_position_to_tile(label, next_to_wall_pos)
	label.name = "%s,%s" % [next_to_wall_pos.x, next_to_wall_pos.y]


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

	var label := $RockNumbers/RockNumbersContainer.get_node("%s,%s" % [pos.x, pos.y])

	for x: int in range(pos.x - 1, tilemap.get_used_rect().position.x - 1, -1):
		var next_cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_rocks, Vector2i(x, pos.y))
		if (
			next_cell_atlas_coords == atlas_coords_round_rock or
			next_cell_atlas_coords == atlas_coords_square_rock
		):
			var new_pos := Vector2i(x + 1, pos.y)
			tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
			tilemap.set_cell(tilemap_layer_rocks, new_pos, 0, atlas_coords_round_rock)
			set_label_center_global_position_to_tile(label, new_pos)
			label.name = "%s,%s" % [new_pos.x, new_pos.y]
			return

	var next_to_wall_pos := Vector2i(tilemap.get_used_rect().position.x, pos.y)
	tilemap.set_cell(tilemap_layer_rocks, next_to_wall_pos, 0, atlas_coords_round_rock)
	tilemap.set_cell(tilemap_layer_rocks, pos, -1, Vector2i(-1, -1))
	set_label_center_global_position_to_tile(label, next_to_wall_pos)
	label.name = "%s,%s" % [next_to_wall_pos.x, next_to_wall_pos.y]


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
	fingerprint_history.append(get_layout_fingerprint())


func spin_until_pattern_repeats() -> void:
	max_cycles_remaining = 1_000


func get_layout_fingerprint() -> String:
	var sorted_cells := tilemap.get_used_cells(tilemap_layer_rocks)
	sorted_cells.sort()
	#var hashctx := HashingContext.new()
	#hashctx.start(HashingContext.HASH_MD5)
	#hashctx.update(PackedByteArray(sorted_cells))
	#var hashed := hashctx.finish()
	#return hashed.hex_encode()
	return "%x" % [hash(sorted_cells)]


func copy_fingerprint_history() -> void:
	var result := []
	for fingerprint in fingerprint_history:
		result.append([fingerprint, fingerprint_history_cache[fingerprint]])
	DisplayServer.clipboard_set(str(result))
