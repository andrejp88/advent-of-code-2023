extends GutTest


var day: Day17


var parsed_test_input: Array[Array] = [
	[2, 4, 1, 3, 4, 3, 2, 3, 1, 1, 3, 2, 3],
	[3, 2, 1, 5, 4, 5, 3, 5, 3, 5, 6, 2, 3],
	[3, 2, 5, 5, 2, 4, 5, 6, 5, 4, 2, 5, 4],
	[3, 4, 4, 6, 5, 8, 5, 8, 4, 5, 4, 5, 2],
	[4, 5, 4, 6, 6, 5, 7, 8, 6, 7, 5, 3, 6],
	[1, 4, 3, 8, 5, 9, 8, 7, 9, 8, 4, 5, 4],
	[4, 4, 5, 7, 8, 7, 6, 9, 8, 7, 7, 6, 6],
	[3, 6, 3, 7, 8, 7, 7, 9, 7, 9, 6, 5, 3],
	[4, 6, 5, 4, 9, 6, 7, 9, 8, 6, 8, 8, 7],
	[4, 5, 6, 4, 6, 7, 9, 9, 8, 6, 4, 5, 3],
	[1, 2, 2, 4, 6, 8, 6, 8, 6, 5, 5, 6, 3],
	[2, 5, 4, 6, 5, 4, 8, 8, 8, 7, 7, 3, 5],
	[4, 3, 2, 2, 6, 7, 4, 6, 5, 5, 5, 3, 3],
]


func before_each() -> void:
	day = preload("res://src/day_17/day_17.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_17/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 102)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_17/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 17, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_17/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_17/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 17, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_17/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.parse_input(input), parsed_test_input)


func test_find_shortest_path() -> void:
	var best_path := await day.find_shortest_path_a_star_iterative_fixed(parsed_test_input, Vector2i(0, 0), Vector2i(12, 12))
	assert_eq(day.calculate_path_cost(parsed_test_input, best_path), 102)
