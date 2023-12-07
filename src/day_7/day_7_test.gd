extends GutTest


var day: Day7


func before_each() -> void:
	day = preload("res://src/day_7/day_7.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_7/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 6440)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_7/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 7, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_7/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_7/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 7, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_get_hand_type() -> void:
	assert_eq(day.get_hand_type("AAAAA"), Day7.HandType.five_of_a_kind)
	assert_eq(day.get_hand_type("AA8AA"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type("23332"), Day7.HandType.full_house)
	assert_eq(day.get_hand_type("TTT98"), Day7.HandType.three_of_a_kind)
	assert_eq(day.get_hand_type("23432"), Day7.HandType.two_pair)
	assert_eq(day.get_hand_type("A23A4"), Day7.HandType.one_pair)
	assert_eq(day.get_hand_type("23456"), Day7.HandType.high_card)
