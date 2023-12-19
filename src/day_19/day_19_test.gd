extends GutTest


var day: Day19

const test_input_parsed := [
	{
		"px": [{ "cat": "a",  "rel": "<", "ref": 2006, "next": "qkq" }, { "cat": "m", "rel": ">", "ref": 2090, "next": "A" }, "rfg" ],
		"pv": [{ "cat": "a",  "rel": ">", "ref": 1716, "next": "R" }, "A" ],
		"lnx": [{ "cat": "m",  "rel": ">", "ref": 1548, "next": "A" }, "A" ],
		"rfg": [{ "cat": "s",  "rel": "<", "ref": 537, "next": "gd" }, { "cat": "x",  "rel": ">", "ref": 2440, "next": "R" }, "A" ],
		"qs": [{ "cat": "s",  "rel": ">", "ref": 3448, "next": "A" }, "lnx" ],
		"qkq": [{ "cat": "x",  "rel": "<", "ref": 1416, "next": "A" }, "crn" ],
		"crn": [{ "cat": "x",  "rel": ">", "ref": 2662, "next": "A" }, "R" ],
		"in": [{ "cat": "s",  "rel": "<", "ref": 1351, "next": "px" }, "qqz" ],
		"qqz": [{ "cat": "s",  "rel": ">", "ref": 2770, "next": "qs" }, { "cat": "m", "rel": "<", "ref": 1801, "next": "hdj" }, "R" ],
		"gd": [{ "cat": "a",  "rel": ">", "ref": 3333, "next": "R" }, "R" ],
		"hdj": [{ "cat": "m",  "rel": ">", "ref": 838, "next": "A" }, "pv"],
	},
	[
		{ "x": 787, "m": 2655, "a": 1222, "s": 2876 },
		{ "x": 1679, "m": 44, "a": 2067, "s": 496 },
		{ "x": 2036, "m": 264, "a": 79, "s": 2244 },
		{ "x": 2461, "m": 1339, "a": 466, "s": 291 },
		{ "x": 2127, "m": 1623, "a": 2188, "s": 1013 },
	]
]


func before_each() -> void:
	day = preload("res://src/day_19/day_19.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_19/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 19114)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_19/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 19, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_19/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_19/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day X, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_19/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var result := day.parse_input(input)

	assert_eq(result, test_input_parsed)


func test_WorkflowProcessor_process() -> void:
	var wp := day.WorkflowProcessor.new(test_input_parsed[0])

	var parts := test_input_parsed[1]

	assert_true(wp.process(parts[0]))
	assert_false(wp.process(parts[1]))
	assert_true(wp.process(parts[2]))
	assert_false(wp.process(parts[3]))
	assert_true(wp.process(parts[4]))
