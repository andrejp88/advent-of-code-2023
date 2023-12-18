extends Node2D


var day17: Day17 = preload("res://src/day_17/day_17.gd").new()
var parsed: Array[Array]


func _ready() -> void:
	day17.draw_path.connect(draw_path)


func load_and_repopulate(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:
	parsed = day17.parse_input(input)

	var tilemap: TileMap = $TileMap
	tilemap.clear()

	for y: int in parsed.size():
		for x: int in parsed[0].size():
			var value: int = parsed[y][x]
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(value - 1, 0))


func _on_find_best_path_part_1_button_pressed() -> void:
	var tilemap: TileMap = $TileMap
	var rect := tilemap.get_used_rect()
	var size := rect.size + Vector2i(-1, -1)
	var destination := size

	day17.find_shortest_path_a_star_iterative_fixed(
		parsed,
		Vector2i.ZERO,
		destination,
		func(position: Vector2i, end: Vector2i) -> int:
			return absi(end.x - position.x) + absi(end.y - position.y),
		0,
		3,
		get_tree(),
		100,
	)


func _on_find_best_path_part_2_button_pressed() -> void:
	var tilemap: TileMap = $TileMap
	var rect := tilemap.get_used_rect()
	var size := rect.size + Vector2i(-1, -1)
	var destination := size

	day17.find_shortest_path_a_star_iterative_fixed(
		parsed,
		Vector2i.ZERO,
		destination,
		func(position: Vector2i, end: Vector2i) -> int:
			return absi(end.x - position.x) + absi(end.y - position.y),
		4,
		10,
		get_tree(),
		100,
	)


func draw_path(path: Array[Vector2i], open_set_size: int = 0) -> void:
	var tilemap: TileMap = $TileMap
	tilemap.clear_layer(1)
	for step: Vector2i in path:
		tilemap.set_cell(1, step, 0, Vector2i(0, 1))

	var heat_loss := day17.calculate_path_cost(parsed, path)
	$CanvasLayer/VBoxContainer/HBoxContainer2/Label2.text = str(heat_loss)
	$CanvasLayer/VBoxContainer/HBoxContainer2/Label4.text = str(open_set_size)
