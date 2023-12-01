extends GutTest


func test_get_calibration_value_part_1() -> void:
	var day_1 := preload("res://src/day_1/day_1.gd").new()
	assert_eq(day_1.get_calibration_value_part_1("1"), 11)
	assert_eq(day_1.get_calibration_value_part_1("1abc2"), 12)
	assert_eq(day_1.get_calibration_value_part_1("pqr3stu8vwx"), 38)
	assert_eq(day_1.get_calibration_value_part_1("a1b2c3d4e5f"), 15)
	assert_eq(day_1.get_calibration_value_part_1("treb7uchet"), 77)
	day_1.free()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_1/test_input_part_1.txt", FileAccess.READ)
	var test_input := fa.get_as_text()
	fa.close()

	var day_1 := preload("res://src/day_1/day_1.gd").new()
	assert_eq(day_1.part_1(test_input), 142)
	day_1.free()


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_1/input.txt", FileAccess.READ)
	var test_input := fa.get_as_text()
	fa.close()

	var day_1 := preload("res://src/day_1/day_1.gd").new()
	print("Day 1, Part 1: ", day_1.part_1(test_input))
	day_1.free()


func test_get_calibration_value_part_2() -> void:
	var day_1 := preload("res://src/day_1/day_1.gd").new()
	assert_eq(day_1.get_calibration_value_part_2("two1nine"), 29)
	assert_eq(day_1.get_calibration_value_part_2("eightwothree"), 83)
	assert_eq(day_1.get_calibration_value_part_2("abcone2threexyz"), 13)
	assert_eq(day_1.get_calibration_value_part_2("xtwone3four"), 24)
	assert_eq(day_1.get_calibration_value_part_2("4nineeightseven2"), 42)
	assert_eq(day_1.get_calibration_value_part_2("zoneight234"), 14)
	assert_eq(day_1.get_calibration_value_part_2("7pqrstsixteen"), 76)
	day_1.free()


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_1/test_input_part_2.txt", FileAccess.READ)
	var test_input := fa.get_as_text()
	fa.close()

	var day_1 := preload("res://src/day_1/day_1.gd").new()
	assert_eq(day_1.part_2(test_input), 281)
	day_1.free()


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_1/input.txt", FileAccess.READ)
	var test_input := fa.get_as_text()
	fa.close()

	var day_1 := preload("res://src/day_1/day_1.gd").new()
	print(day_1.part_2(test_input))
	day_1.free()
