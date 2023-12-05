extends GutTest


var day_5: Day5
const test_input_parsed := {
	"seeds": [79, 14, 55, 13],
	"seed-to-soil": {
		[98, 2]: 50,
		[50, 48]: 52,
	},
	"soil-to-fertilizer": {
		[15, 37]: 0,
		[52, 2]: 37,
		[0, 15]: 39,
	},
	"fertilizer-to-water": {
		[53, 8]: 49,
		[11, 42]: 0,
		[0, 7]: 42,
		[7, 4]: 57,
	},
	"water-to-light": {
		[18, 7]: 88,
		[25, 70]: 18,
	},
	"light-to-temperature": {
		[77, 23]: 45,
		[45, 19]: 81,
		[64, 13]: 68,
	},
	"temperature-to-humidity": {
		[69, 1]: 0,
		[0, 69]: 1,
	},
	"humidity-to-location": {
		[56, 37]: 60,
		[93, 4]: 56,
	},
}


func before_each() -> void:
	day_5 = Day5.new()


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_5/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var parsed := day_5.parse_input(input)

	assert_eq(parsed, test_input_parsed)


func test_get_location_for_seed() -> void:
	assert_eq(day_5.get_location_for_seed(test_input_parsed, 79), 82)
	assert_eq(day_5.get_location_for_seed(test_input_parsed, 14), 43)
	assert_eq(day_5.get_location_for_seed(test_input_parsed, 55), 86)
	assert_eq(day_5.get_location_for_seed(test_input_parsed, 13), 35)


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_5/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day_5.part_1(input), 35)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_5/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 5, Part 1: ", day_5.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_5/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day_5.part_2(input), 46)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_5/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 5, Part 2: ", day_5.part_2(input))
	pass_test("passed")
