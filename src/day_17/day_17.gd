class_name Day17

const Util := preload("res://src/util.gd")


func part_1(input: String) -> int:
	return 0


func part_2(input: String) -> int:
	return 0


func parse_input(input: String) -> Array[Array]:
	var result: Array[Array] = []

	result.assign(Array(input.split("\n", false)).map(
		func(line: String) -> Array[int]:
			var result_inner: Array[int] = []
			result_inner.assign(Array(line.split("")).map(
					func(character: String) -> int:
						return int(character)
			))
			return result_inner
	))

	return result


signal draw_path(path: Array[Vector2i])

func find_shortest_path_a_star_iterative_fixed(
	world: Array[Array],
	start: Vector2i,
	end: Vector2i,
	tree: SceneTree = null,
	draw_path_interval: int = 100,
) -> Array[Vector2i]:

	var world_rect := Rect2i(0, 0, world[0].size(), world.size())
	var open_set: Array = [[start, []]]
	var came_from := {}
	var g_score := { [start, []]: 0 }
	var f_score := { [start, []]: heuristic(start, end) }

	var iterations_since_draw_path := 0

	while not open_set.is_empty():

		var current: Array
		var current_f_score := 2 ** 32

		for candidate: Array in open_set:
			if f_score[candidate] < current_f_score:
				current_f_score = f_score[candidate]
				current = candidate

		open_set.erase(current)

		var current_pos: Vector2i = current[0]
		var current_recent_directions_travelled: Array[Vector2i] = []
		current_recent_directions_travelled.assign(current[1])

		if current_pos == Vector2i(11, 11):
			pass

		var direction_to_avoid := Vector2i.ZERO

		if current_recent_directions_travelled.size() >= 3 and has_only_one_unique_value(current_recent_directions_travelled):
			direction_to_avoid = current_recent_directions_travelled[0]

		var current_path := reconstruct_path(came_from, current_pos, current_recent_directions_travelled)

		iterations_since_draw_path += 1

		if iterations_since_draw_path > draw_path_interval:
			iterations_since_draw_path -= draw_path_interval
			draw_path.emit(current_path, open_set.size())
			if tree != null:
				await tree.process_frame

		if current_pos == end:
			draw_path.emit(current_path, open_set.size())
			return current_path

		for direction: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbour_pos := current_pos + direction
			var neighbour_recent_directions_travelled := current_recent_directions_travelled.duplicate()

			if neighbour_recent_directions_travelled.size() == 3:
				neighbour_recent_directions_travelled.pop_back()

			neighbour_recent_directions_travelled.push_front(direction)

			var neighbour := [neighbour_pos, neighbour_recent_directions_travelled]

			if not world_rect.has_point(neighbour_pos):
				continue

			# If this neighbour would mean either going too far in one direction *or* reversing, ignore this neighbour.
			if (
				direction == direction_to_avoid or
				(current_recent_directions_travelled.size() > 0 and direction == current_recent_directions_travelled[0] * -1)
			):
				continue

			var tentative_g_score: int = g_score.get(current, 2 ** 32) + world[neighbour_pos.y][neighbour_pos.x]

			if tentative_g_score < g_score.get(neighbour, 2 ** 32):
				came_from[neighbour] = current
				g_score[neighbour] = tentative_g_score
				f_score[neighbour] = tentative_g_score + heuristic(neighbour_pos, end)

				if neighbour not in open_set:
					open_set.push_back(neighbour)

	return []


func heuristic(start: Vector2i, end: Vector2i) -> int:
	return absi(end.x - start.x) + absi(end.y - start.y)


func reconstruct_path(came_from: Dictionary, end: Vector2i, recent_directions_travelled: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = [end]
	var current := [end, recent_directions_travelled]

	while current in came_from:
		current = came_from[current]
		result.push_front(current[0])

	return result


func has_only_one_unique_value(arr: Array) -> bool:
	if arr.size() == 0:
		return true # I guess

	var first: Variant = arr[0]

	for i: int in range(1, arr.size()):
		if arr[i] != first:
			return false

	return true


func calculate_path_cost(world: Array[Array], path: Array[Vector2i]) -> int:
	return path.reduce(
		func(acc: int, step: Vector2i) -> int:
			return acc + world[step.y][step.x],
		0
	) - world[path[0].y][path[0].x] # Subtract the first spot since it doesn't count
