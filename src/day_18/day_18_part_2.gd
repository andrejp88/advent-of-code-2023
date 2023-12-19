class_name Day18Part2

const Util := preload("res://src/util.gd")


signal partition_iterated


func part_2(input: String) -> int:

	var commands := parse_input(input)
	var polygon := construct_polygon(commands)

	return 0


func parse_input(input: String) -> Array[Array]:
	var result: Array[Array] = []

	result.assign(Array(input.split("\n", false)).map(
		func(line: String) -> Array:
			var parts := line.split(" ")

			var _direction := parts[0]
			var _distance := parts[1]
			var color := parts[2]

			var real_distance_hex := color.substr(2, 5)
			var real_direction_numeric := color.substr(7, 1)

			var real_direction := ""
			match real_direction_numeric:
				"0": real_direction = "R"
				"1": real_direction = "D"
				"2": real_direction = "L"
				"3": real_direction = "U"

			var real_distance := real_distance_hex.hex_to_int()

			return [real_direction, real_distance]
	))

	return result


func construct_polygon(commands: Array[Array]) -> Array[Vector2i]:
	var polygon: Array[Vector2i] = [Vector2i(0, 0)]

	# This array will be zipped+added to the polygon to ensure that "end" vertices are exclusive
	var corrections_for_exclusivity: Array[Vector2i] = [Vector2i(0, 0)]

	for command_idx: int in commands.size():
		var command := commands[command_idx]
		var new_point_delta := Vector2i.ZERO
		var current_direction: String = command[0]

		match current_direction:
			"U": new_point_delta.y -= command[1]
			"D": new_point_delta.y += command[1]
			"L": new_point_delta.x -= command[1]
			"R": new_point_delta.x += command[1]

		var new_point := polygon[polygon.size() - 1] + new_point_delta
		polygon.push_back(new_point)

		var next_command_idx := (
			command_idx + 1
			if command_idx < commands.size() - 1 else
			0
		)

		var next_direction: String = commands[next_command_idx][0]
		var directions := [current_direction, next_direction]
		directions.sort()

		# This only applies if the polygon is clockwise.
		# If it's counter-clockwise, RU <=> DL and LU <=> DR
		# Hoping the real input is clockwise
		match directions:
			["R", "U"]:
				corrections_for_exclusivity.push_back(Vector2i(0, 0))
			["D", "R"]:
				corrections_for_exclusivity.push_back(Vector2i(1, 0))
			["L", "U"]:
				corrections_for_exclusivity.push_back(Vector2i(0, 1))
			["D", "L"]:
				corrections_for_exclusivity.push_back(Vector2i(1, 1))

	polygon.pop_back()

	for idx: int in polygon.size():
		polygon[idx] += corrections_for_exclusivity[idx]

	return polygon


func partition_polygon(polygon: Array[Vector2i], wait_for: Signal = Signal(null, "dummy")) -> Array[Rect2i]:
	var result: Array[Rect2i] = []

	var polygon_remaining: Array[Vector2i] = polygon.duplicate()
	var sorted_vertices: Array[Vector2i] = polygon.duplicate()
	sorted_vertices.sort_custom(vector2i_sort_y_then_x)

	while sorted_vertices.size() >= 2:
		var top_left_most_vertex := sorted_vertices[0]
		var top_second_left_most_vertex := sorted_vertices[1]
		var index_of_top_left_most_vertex := polygon_remaining.find(top_left_most_vertex)
		var rect_corner_candidate_left := polygon_remaining[index_of_top_left_most_vertex - 1]
		var rect_corner_candidate_right := polygon_remaining[(index_of_top_left_most_vertex + 2) % polygon_remaining.size()]

		print("Start of loop: sorted_vertices = ", sorted_vertices)
		print("top_left_most_vertex: ", top_left_most_vertex)
		print("top_second_left_most_vertex: ", top_second_left_most_vertex)
		print("index_of_top_left_most_vertex: ", index_of_top_left_most_vertex)
		print("rect_corner_candidate_left: ", rect_corner_candidate_left)
		print("rect_corner_candidate_right: ", rect_corner_candidate_right)

		if rect_corner_candidate_left.y == rect_corner_candidate_right.y:
			var rect_bottom_right_corner := rect_corner_candidate_right
			var rect_size := rect_bottom_right_corner - top_left_most_vertex
			result.append(Rect2i(top_left_most_vertex, rect_size))

			print("corners are equal")

			if rect_corner_candidate_left.x > polygon_remaining[index_of_top_left_most_vertex - 2].x:
				sorted_vertices.erase(rect_corner_candidate_left)
				polygon_remaining.erase(rect_corner_candidate_left)

			if rect_corner_candidate_right.x < polygon_remaining[(index_of_top_left_most_vertex + 3) % polygon_remaining.size()].x:
				sorted_vertices.erase(rect_corner_candidate_right)
				polygon_remaining.erase(rect_corner_candidate_right)


		elif rect_corner_candidate_left.y < rect_corner_candidate_right.y:
			var rect_bottom_right_corner := Vector2i(rect_corner_candidate_right.x, rect_corner_candidate_left.y)
			var rect_size := rect_bottom_right_corner - top_left_most_vertex
			result.append(Rect2i(top_left_most_vertex, rect_size))

			var new_synthetic_vertex := Vector2i(rect_bottom_right_corner.x, rect_corner_candidate_left.y)
			var new_synthetic_vertex_idx := sorted_vertices.bsearch_custom(
				new_synthetic_vertex,
				vector2i_sort_y_then_x,
			)

			sorted_vertices.insert(new_synthetic_vertex_idx, new_synthetic_vertex)
			polygon_remaining.insert((index_of_top_left_most_vertex + 2) % polygon_remaining.size(), new_synthetic_vertex)

			sorted_vertices.erase(rect_corner_candidate_left)
			polygon_remaining.erase(rect_corner_candidate_left)

			print("left corner is higher, erasing rect_corner_candidate_left and inserting ", new_synthetic_vertex)

		else:
			var rect_bottom_right_corner := rect_corner_candidate_right
			var rect_size := rect_bottom_right_corner - top_left_most_vertex
			result.append(Rect2i(top_left_most_vertex, rect_size))

			var new_synthetic_vertex := Vector2i(rect_corner_candidate_left.x, rect_bottom_right_corner.y)
			var new_synthetic_vertex_idx := sorted_vertices.bsearch_custom(
				new_synthetic_vertex,
				vector2i_sort_y_then_x,
			)

			sorted_vertices.insert(new_synthetic_vertex_idx, new_synthetic_vertex)
			polygon_remaining.insert(index_of_top_left_most_vertex, new_synthetic_vertex)

			sorted_vertices.erase(rect_corner_candidate_right)
			polygon_remaining.erase(rect_corner_candidate_right)

			print("right corner is higher, erasing rect_corner_candidate_right and inserting ", new_synthetic_vertex)

		sorted_vertices.erase(top_left_most_vertex)
		sorted_vertices.erase(top_second_left_most_vertex)
		polygon_remaining.erase(top_left_most_vertex)
		polygon_remaining.erase(top_second_left_most_vertex)
		print("erasing top_left_most_vertex and top_second_left_most_vertex")
		print("End of loop: sorted_vertices = ", sorted_vertices)
		print()

		partition_iterated.emit(polygon_remaining, result)

		if wait_for.get_name() != "dummy":
			await wait_for

	return result.filter(
		func(rect: Rect2i) -> bool:
			return rect.has_area()
	)


func vector2i_sort_y_then_x(a: Vector2i, b: Vector2i) -> bool:
	return (
		(b.y > a.y) or
		(b.y == a.y and b.x > a.x)
	)
