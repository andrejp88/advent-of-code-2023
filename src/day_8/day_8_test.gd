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
	var fa := FileAccess.open("res://src/day_8/test_input_part_2.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 6)


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

	assert_eq(day.calculate_distance(network, instructions, "AAA", func(node: String) -> bool: return node == "ZZZ"), 2)



func test_calculate_distance_example_2() -> void:
	var instructions := "LLR"
	var network := {
		"AAA": ["BBB", "BBB"],
		"BBB": ["AAA", "ZZZ"],
		"ZZZ": ["ZZZ", "ZZZ"],
	}

	assert_eq(day.calculate_distance(network, instructions, "AAA", func(node: String) -> bool: return node == "ZZZ"), 6)


func test_gcd() -> void:
	assert_eq(day.gcd(1, 1), 1)
	assert_eq(day.gcd(6, 4), 2)
	assert_eq(day.gcd(9, 6), 3)
	assert_eq(day.gcd(21, 49), 7)


func test_lcm() -> void:
	assert_eq(day.lcm(1, 1), 1)
	assert_eq(day.lcm(6, 4), 12)
	assert_eq(day.lcm(9, 6), 18)
	assert_eq(day.lcm(21, 49), 147)


func test_lcm_n() -> void:
	assert_eq(day.lcm_n([1, 2]), 2)
	assert_eq(day.lcm_n([1, 2, 3]), 6)
	assert_eq(day.lcm_n([1, 2, 3, 4]), 12)
