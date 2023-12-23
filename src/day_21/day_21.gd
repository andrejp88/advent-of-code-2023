class_name Day21

const Util := preload("res://src/util.gd")


func part_1(input: String, num_steps: int) -> int:
	var grid: Array[String] = []
	grid.assign(Array(input.split("\n", false)))
	var grid_rect := Rect2i(Vector2i.ZERO, Vector2i(grid[0].length(), grid.size()))

	var start_pos := Vector2i(-1, -1)

	for row_idx: int in grid.size():
		var row := grid[row_idx]
		var s_idx := row.find("S")
		if s_idx >= 0:
			start_pos = Vector2i(row_idx, s_idx)
			break

	var next_steps: Array[Dictionary] = [{ "pos": start_pos, "steps_remaining": num_steps, "path": [] }]
	var gardens_visited: Array[Vector2i] = []
	var steps_already_considered: Dictionary = {}

	while not next_steps.is_empty():
		var current_step: Dictionary = next_steps.pop_front()
		var current_pos: Vector2i = current_step["pos"]
		var steps_remaining: int = current_step["steps_remaining"]
		var current_step_descriptor := "%s %s" % [current_pos, steps_remaining]

		if current_step_descriptor in steps_already_considered:
			continue

		steps_already_considered[current_step_descriptor] = true

		if (
			steps_remaining == 0 and
			grid[current_pos.y][current_pos.x] in ["S", "."] and
			current_pos not in gardens_visited
		):
			gardens_visited.push_back(current_pos)
			continue

		var neighbours: Array[Vector2i] = [current_pos + Vector2i.UP, current_pos + Vector2i.DOWN, current_pos + Vector2i.RIGHT, current_pos + Vector2i.LEFT]
		for neighbour in neighbours:
			if grid_rect.has_point(neighbour) and grid[neighbour.y][neighbour.x] != "#":
				next_steps.push_back({
					"pos": neighbour,
					"steps_remaining": steps_remaining - 1,
					"path": current_step["path"] + [current_pos]
				})


	return gardens_visited.size()


func part_2(input: String) -> int:
	return 0

