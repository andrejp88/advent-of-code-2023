extends GutTest


var day: Day21


func before_each() -> void:
	day = preload("res://src/day_21/day_21.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_21/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input, 6), 16)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_21/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 21, Part 1: ", day.part_1(input, 64))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_21/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_21/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 21, Part 2: ", day.part_2(input))
	pass_test("passed")

