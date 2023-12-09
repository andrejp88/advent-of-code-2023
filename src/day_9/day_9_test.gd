extends GutTest


var day: Day9


func before_each() -> void:
	day = preload("res://src/day_9/day_9.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_9/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 114)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_9/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 9, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_9/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 2)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_9/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 9, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_9/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.parse_input(input), [
		[ 0,  3,  6,  9, 12, 15],
		[ 1,  3,  6, 10, 15, 21],
		[10, 13, 16, 21, 30, 45],
	])


func test_extrapolate_next() -> void:
	assert_eq(day.extrapolate_next([1, 1, 1, 1]), [1, 1, 1, 1, 1])
	assert_eq(day.extrapolate_next([1, 2, 3, 4]), [1, 2, 3, 4, 5])
	assert_eq(day.extrapolate_next([4, 5, 7, 10, 14]), [4, 5, 7, 10, 14, 19])
	assert_eq(day.extrapolate_next([2, 5, 9, 15, 24]), [2, 5, 9, 15, 24, 37])


func test_get_first_derivative() -> void:
	assert_eq(day.get_first_derivative([1, 1, 1, 1]), [0, 0, 0])
	assert_eq(day.get_first_derivative([1, 2, 3, 4]), [1, 1, 1])
	assert_eq(day.get_first_derivative([4, 5, 7, 10, 14]), [1, 2, 3, 4])
	assert_eq(day.get_first_derivative([2, 5, 9, 15, 24]), [3, 4, 6, 9])
