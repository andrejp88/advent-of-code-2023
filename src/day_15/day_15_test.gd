extends GutTest


var day: Day15


func before_each() -> void:
	day = preload("res://src/day_15/day_15.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_15/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 1320)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_15/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 15, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_15/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 123_456_789)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_15/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 15, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_holiday_hash() -> void:
	assert_eq(day.holiday_hash("HASH"), 52)
	assert_eq(day.holiday_hash("rn=1"), 30)
	assert_eq(day.holiday_hash("cm-"), 253)
	assert_eq(day.holiday_hash("qp=3"), 97)
	assert_eq(day.holiday_hash("cm=2"), 47)
	assert_eq(day.holiday_hash("qp-"), 14)
	assert_eq(day.holiday_hash("pc=4"), 180)
	assert_eq(day.holiday_hash("ot=9"), 9)
	assert_eq(day.holiday_hash("ab=5"), 197)
	assert_eq(day.holiday_hash("pc-"), 48)
	assert_eq(day.holiday_hash("pc=6"), 214)
	assert_eq(day.holiday_hash("ot=7"), 231)
