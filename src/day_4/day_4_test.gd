extends GutTest


var day_4: Day4


func before_each() -> void:
	day_4 = preload("res://src/day_4/day_4.gd").new()


func test_parse_card() -> void:
	assert_eq(day_4.parse_card("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53"), { "winning_numbers": [41, 48, 83, 86, 17], "owned_numbers": [83, 86,  6, 31, 17,  9, 48, 53]})
	assert_eq(day_4.parse_card("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19"), { "winning_numbers": [13, 32, 20, 16, 61], "owned_numbers": [61, 30, 68, 82, 17, 32, 24, 19]})
	assert_eq(day_4.parse_card("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1"), { "winning_numbers": [1, 21, 53, 59, 44], "owned_numbers": [69, 82, 63, 72, 16, 21, 14,  1]})
	assert_eq(day_4.parse_card("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83"), { "winning_numbers": [41, 92, 73, 84, 69], "owned_numbers": [59, 84, 76, 51, 58,  5, 54, 83]})
	assert_eq(day_4.parse_card("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36"), { "winning_numbers": [87, 83, 26, 28, 32], "owned_numbers": [88, 30, 70, 12, 93, 22, 82, 36]})
	assert_eq(day_4.parse_card("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"), { "winning_numbers": [31, 18, 13, 56, 72], "owned_numbers": [74, 77, 10, 23, 35, 67, 36, 11]})


func test_get_point_value_of_line() -> void:
	assert_eq(day_4.get_number_of_matches({ "winning_numbers": [41, 48, 83, 86, 17], "owned_numbers": [83, 86,  6, 31, 17,  9, 48, 53]}), 4)
	assert_eq(day_4.get_number_of_matches({ "winning_numbers": [13, 32, 20, 16, 61], "owned_numbers": [61, 30, 68, 82, 17, 32, 24, 19]}), 2)
	assert_eq(day_4.get_number_of_matches({ "winning_numbers": [1, 21, 53, 59, 44], "owned_numbers": [69, 82, 63, 72, 16, 21, 14,  1]}), 2)
	assert_eq(day_4.get_number_of_matches({ "winning_numbers": [41, 92, 73, 84, 69], "owned_numbers": [59, 84, 76, 51, 58,  5, 54, 83]}), 1)
	assert_eq(day_4.get_number_of_matches({ "winning_numbers": [87, 83, 26, 28, 32], "owned_numbers": [88, 30, 70, 12, 93, 22, 82, 36]}), 0)
	assert_eq(day_4.get_number_of_matches({ "winning_numbers": [31, 18, 13, 56, 72], "owned_numbers": [74, 77, 10, 23, 35, 67, 36, 11]}), 0)


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_4/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day_4.part_1(input), 13)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_4/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 4, Part 1: ", day_4.part_1(input))
	pass_test("passed")
