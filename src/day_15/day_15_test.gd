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

	assert_eq(day.part_2(input), 145)


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


func test_operate_on_lenses() -> void:
	var boxes: Array[Day15.Box] = []
	boxes.resize(256)

	for idx: int in boxes.size():
		boxes[idx] = Day15.Box.new()

	day.operate_on_boxes("rn=1", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}])

	day.operate_on_boxes("cm-", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}])

	day.operate_on_boxes("qp=3", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}])
	assert_eq(boxes[1].lenses, [{"label": "qp", "focal_length": 3}])

	day.operate_on_boxes("cm=2", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[1].lenses, [{"label": "qp", "focal_length": 3}])

	day.operate_on_boxes("qp-", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[1].lenses, [])

	day.operate_on_boxes("pc=4", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[3].lenses, [{"label": "pc", "focal_length": 4}])

	day.operate_on_boxes("ot=9", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[3].lenses, [{"label": "pc", "focal_length": 4}, {"label": "ot", "focal_length": 9}])

	day.operate_on_boxes("ab=5", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[3].lenses, [{"label": "pc", "focal_length": 4}, {"label": "ot", "focal_length": 9}, {"label": "ab", "focal_length": 5}])

	day.operate_on_boxes("pc-", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[3].lenses, [{"label": "ot", "focal_length": 9}, {"label": "ab", "focal_length": 5}])

	day.operate_on_boxes("pc=6", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[3].lenses, [{"label": "ot", "focal_length": 9}, {"label": "ab", "focal_length": 5}, {"label": "pc", "focal_length": 6}])

	day.operate_on_boxes("ot=7", boxes)
	assert_eq(boxes[0].lenses, [{"label": "rn", "focal_length": 1}, {"label": "cm", "focal_length": 2}])
	assert_eq(boxes[3].lenses, [{"label": "ot", "focal_length": 7}, {"label": "ab", "focal_length": 5}, {"label": "pc", "focal_length": 6}])
