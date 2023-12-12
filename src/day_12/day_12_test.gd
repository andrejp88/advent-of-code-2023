extends GutTest


var day: Day12
var test_input_parsed := [
	Day12.Row.new(
		[Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged],
		[1, 1, 3],
	),
	Day12.Row.new(
		[Day12.Condition.operational, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.operational],
		[1, 1, 3],
	),
	Day12.Row.new(
		[Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.unknown],
		[1, 3, 1, 6],
	),
	Day12.Row.new(
		[Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.operational],
		[4, 1, 1],
	),
	Day12.Row.new(
		[Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.operational, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.operational],
		[1, 6, 5],
	),
	Day12.Row.new(
		[Day12.Condition.unknown, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown, Day12.Condition.unknown],
		[3, 2, 1],
	),
]


func assert_rows_eq(got: Day12.Row, expected: Day12.Row) -> void:
	assert_eq(got.conditions, expected.conditions)
	assert_eq(got.range_sizes, expected.range_sizes)


func before_each() -> void:
	day = preload("res://src/day_12/day_12.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_12/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 21)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_12/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 12, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_12/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_12/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 12, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_12/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var result := day.parse_input(input)
	assert_eq(result.size(), test_input_parsed.size())

	for i: int in result.size():
		assert_rows_eq(result[i], test_input_parsed[i])


func test_calculate_possible_arrangements() -> void:
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[0]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[1]), 4)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[2]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[3]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[4]), 4)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[5]), 10)


func test_describe_damaged_ranges() -> void:
	assert_eq(
		day.describe_damaged_ranges([Day12.Condition.damaged, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged]),
		[1, 1, 3],
	)

	assert_eq(
		day.describe_damaged_ranges([Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.damaged, Day12.Condition.damaged]),
		[3, 3],
	)

	assert_eq(
		day.describe_damaged_ranges([Day12.Condition.damaged]),
		[1],
	)

	assert_eq(
		day.describe_damaged_ranges([Day12.Condition.operational, Day12.Condition.damaged, Day12.Condition.operational]),
		[1],
	)

	assert_eq(
		day.describe_damaged_ranges([Day12.Condition.operational]),
		[],
	)
