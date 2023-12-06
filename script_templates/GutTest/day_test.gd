extends GutTest


var day: Day


func before_each() -> void:
	pass # day = preload("res://script_templates/day.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("<path to test input>", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 123_456_789)


func test_part_1_real() -> void:
	var fa := FileAccess.open("<path to real input>", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day X, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("<path to test input>", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("<path to real input>", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day X, Part 2: ", day.part_2(input))
	pass_test("passed")
