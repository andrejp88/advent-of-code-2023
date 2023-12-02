extends GutTest

var day_2: Day2


func before_each() -> void:
	day_2 = preload("res://src/day_2/day_2.gd").new()


func test_parse_game() -> void:
	assert_eq(day_2.parse_game("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"), [[4, 0, 3], [1, 2, 6], [0, 2, 0]])
	assert_eq(day_2.parse_game("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue"), [[0, 2, 1], [1, 3, 4], [0, 1, 1]])
	assert_eq(day_2.parse_game("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"), [[20, 8, 6], [4, 13, 5], [1, 5, 0]])
	assert_eq(day_2.parse_game("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red"), [[3, 1, 6], [6, 3, 0], [14, 3, 15]])
	assert_eq(day_2.parse_game("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"), [[6, 3, 1], [1, 2, 2]])


func test_parse_round() -> void:
	assert_eq(day_2.parse_round("3 blue, 4 red"), [4, 0, 3])
	assert_eq(day_2.parse_round("1 red, 2 green, 6 blue"), [1, 2, 6])
	assert_eq(day_2.parse_round("2 green"), [0, 2, 0])


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_2/test_input.txt", FileAccess.READ)
	var test_input := fa.get_as_text()
	fa.close()

	assert_eq(day_2.part_1(test_input), "8")


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_2/input.txt", FileAccess.READ)
	var test_input := fa.get_as_text()
	fa.close()

	print("Day 2, Part 1: ", day_2.part_1(test_input))
	pass_test("passed")
