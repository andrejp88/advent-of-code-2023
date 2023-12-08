extends GutTest


var day: Day8


func before_each() -> void:
	day = preload("res://src/day_8/day_8.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_8/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 2)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_8/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 8, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_8/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_8/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 8, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_8/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.parse_input(input), [
		"RL",
		{
			"AAA": ["BBB", "CCC"],
			"BBB": ["DDD", "EEE"],
			"CCC": ["ZZZ", "GGG"],
			"DDD": ["DDD", "DDD"],
			"EEE": ["EEE", "EEE"],
			"GGG": ["GGG", "GGG"],
			"ZZZ": ["ZZZ", "ZZZ"],
		}
	])


func test_calculate_distance_example_1() -> void:
	var instructions := "RL"
	var network := {
		"AAA": ["BBB", "CCC"],
		"BBB": ["DDD", "EEE"],
		"CCC": ["ZZZ", "GGG"],
		"DDD": ["DDD", "DDD"],
		"EEE": ["EEE", "EEE"],
		"GGG": ["GGG", "GGG"],
		"ZZZ": ["ZZZ", "ZZZ"],
	}

	assert_eq(day.calculate_distance(network, instructions, "AAA", "ZZZ"), 2)



func test_calculate_distance_example_2() -> void:
	var instructions := "LLR"
	var network := {
		"AAA": ["BBB", "BBB"],
		"BBB": ["AAA", "ZZZ"],
		"ZZZ": ["ZZZ", "ZZZ"],
	}

	assert_eq(day.calculate_distance(network, instructions, "AAA", "ZZZ"), 6)
