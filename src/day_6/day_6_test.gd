extends GutTest


var day_6: Day6


func before_each() -> void:
	day_6 = preload("res://src/day_6/day_6.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_6/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day_6.part_1(input), 288)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_6/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day X, Part 1: ", day_6.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_6/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day_6.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_6/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day X, Part 2: ", day_6.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_6/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day_6.parse_input(input), [[7, 9], [15, 40], [30, 200]])


func test_get_distance() -> void:
	assert_eq(day_6.get_distance(7, 0), 0)
	assert_eq(day_6.get_distance(7, 1), 6)
	assert_eq(day_6.get_distance(7, 2), 10)
	assert_eq(day_6.get_distance(7, 3), 12)
	assert_eq(day_6.get_distance(7, 4), 12)
	assert_eq(day_6.get_distance(7, 5), 10)
	assert_eq(day_6.get_distance(7, 6), 6)
	assert_eq(day_6.get_distance(7, 7), 0)
