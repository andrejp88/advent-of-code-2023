extends Node2D


@onready var tilemap: TileMap = $TileMap
var grid: Array[String] = []

var day: Day21 = preload("res://src/day_21/day_21.gd").new()


func _ready() -> void:
	day.pre_step_signal.connect(on_step)
	day.part_1_completed.connect(
		func(num_gardens_visited: int) -> void:
			$CanvasLayer/VBoxContainer/HBoxContainer2/Label2.text = str(num_gardens_visited)
	)


func load_and_repopulate(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()
	grid.assign(Array(input.split("\n", false)))
	repopulate()


func repopulate() -> void:

	tilemap.clear()

	for row_idx: int in grid.size():
		var row := grid[row_idx]
		for col_idx: int in row.length():
			match row[col_idx]:
				".", "S":
					tilemap.set_cell(0, Vector2i(col_idx, row_idx), 0, Vector2i(0, 0))

				"#":
					tilemap.set_cell(0, Vector2i(col_idx, row_idx), 0, Vector2i(1, 0))


func run_part_1(num_steps: int) -> void:
	day.search_part_1(grid, num_steps, get_tree().process_frame, 100)


func on_step(current_pos: Vector2i, next_positions: Array[Vector2i], gardens_visited: Array[Vector2i]) -> void:
	tilemap.clear_layer(1)

	tilemap.set_cell(1, current_pos, 0, Vector2i(2, 1))

	for next_pos in next_positions:
		tilemap.set_cell(1, next_pos, 0, Vector2i(1, 1))

	for garden in gardens_visited:
		tilemap.set_cell(1, garden, 0, Vector2i(0, 1))
