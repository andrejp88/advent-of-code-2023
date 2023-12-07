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

	assert_eq(day.part_2(input), 5905)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_7/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 7, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_get_hand_type_part_1() -> void:
	assert_eq(day.get_hand_type_part_1("AAAAA"), Day7.HandType.five_of_a_kind)
	assert_eq(day.get_hand_type_part_1("AA8AA"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_1("23332"), Day7.HandType.full_house)
	assert_eq(day.get_hand_type_part_1("TTT98"), Day7.HandType.three_of_a_kind)
	assert_eq(day.get_hand_type_part_1("23432"), Day7.HandType.two_pair)
	assert_eq(day.get_hand_type_part_1("A23A4"), Day7.HandType.one_pair)
	assert_eq(day.get_hand_type_part_1("23456"), Day7.HandType.high_card)


func test_get_hand_type_part_2() -> void:
	# The previous examples should work the same
	assert_eq(day.get_hand_type_part_2("AAAAA"), Day7.HandType.five_of_a_kind)
	assert_eq(day.get_hand_type_part_2("AA8AA"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("23332"), Day7.HandType.full_house)
	assert_eq(day.get_hand_type_part_2("TTT98"), Day7.HandType.three_of_a_kind)
	assert_eq(day.get_hand_type_part_2("23432"), Day7.HandType.two_pair)
	assert_eq(day.get_hand_type_part_2("A23A4"), Day7.HandType.one_pair)
	assert_eq(day.get_hand_type_part_2("23456"), Day7.HandType.high_card)

	# But J is now a Joker, and should be treated as whatever makes for the most favorable hand
	# These four examples are from the problem description:
	assert_eq(day.get_hand_type_part_2("QJJQ2"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("T55J5"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("KTJJT"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("QQQJA"), Day7.HandType.four_of_a_kind)

	# And these are my own:
	# Non-joker cards are all different
	assert_eq(day.get_hand_type_part_2("2345J"), Day7.HandType.one_pair)
	assert_eq(day.get_hand_type_part_2("234JJ"), Day7.HandType.three_of_a_kind)
	assert_eq(day.get_hand_type_part_2("23JJJ"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("2JJJJ"), Day7.HandType.five_of_a_kind)

	# Non-joker cards contain a pair already
	assert_eq(day.get_hand_type_part_2("2344J"), Day7.HandType.three_of_a_kind)
	assert_eq(day.get_hand_type_part_2("233JJ"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("22JJJ"), Day7.HandType.five_of_a_kind)

	# Non-joker cards contain a two-pair already
	assert_eq(day.get_hand_type_part_2("2233J"), Day7.HandType.full_house)

	# Non-joker cards contain a three-of-a-kind already
	assert_eq(day.get_hand_type_part_2("2333J"), Day7.HandType.four_of_a_kind)
	assert_eq(day.get_hand_type_part_2("222JJ"), Day7.HandType.five_of_a_kind)

	# Non-joker cards contain a four-of-a-kind already
	assert_eq(day.get_hand_type_part_2("2222J"), Day7.HandType.five_of_a_kind)

	# Oops, all jokers!
	assert_eq(day.get_hand_type_part_2("JJJJJ"), Day7.HandType.five_of_a_kind)
