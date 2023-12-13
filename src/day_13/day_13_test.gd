extends GutTest


var day: Day13


func before_each() -> void:
	day = preload("res://src/day_13/day_13.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_13/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 405)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_13/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 13, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_13/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_13/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 13, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_transpose_lines() -> void:
	assert_eq(
		day.transpose_lines([
			"ABCDEFG",
			"HIJKLMN",
			"OPQRSTU",
			"VWXYZ  "
		]),
		[
			"AHOV",
			"BIPW",
			"CJQX",
			"DKRY",
			"ELSZ",
			"FMT ",
			"GNU ",
		]
	)
