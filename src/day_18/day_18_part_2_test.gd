extends GutTest


var day: Day18Part2

const test_input_parsed: Array[Array] = [
	["R", 461937],
	["D", 56407],
	["R", 356671],
	["D", 863240],
	["R", 367720],
	["D", 266681],
	["L", 577262],
	["U", 829975],
	["L", 112010],
	["D", 829975],
	["L", 491645],
	["U", 686074],
	["L", 5411],
	["U", 500254],
]

func before_each() -> void:
	day = preload("res://src/day_18/day_18_part_2.gd").new()


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_18/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 952_408_144_115)


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_18/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 18, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_18/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.parse_input(input), test_input_parsed)


func test_construct_polygon() -> void:
	const test_input_part_1: Array[Array] = [
		["R", 6],
		["D", 5],
		["L", 2],
		["D", 2],
		["R", 2],
		["D", 2],
		["L", 5],
		["U", 2],
		["L", 1],
		["U", 2],
		["R", 2],
		["U", 3],
		["L", 2],
		["U", 2],
	]

	assert_eq(day.construct_polygon(test_input_part_1), [
		Vector2i(0, 0),
		Vector2i(7, 0),
		Vector2i(7, 6),
		Vector2i(5, 6),
		Vector2i(5, 7),
		Vector2i(7, 7),
		Vector2i(7, 10),
		Vector2i(1, 10),
		Vector2i(1, 8),
		Vector2i(0, 8),
		Vector2i(0, 5),
		Vector2i(2, 5),
		Vector2i(2, 3),
		Vector2i(0, 3),
	])


func test_partition_polygon() -> void:
	var polygon: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(7, 0),
		Vector2i(7, 6),
		Vector2i(5, 6),
		Vector2i(5, 7),
		Vector2i(7, 7),
		Vector2i(7, 10),
		Vector2i(1, 10),
		Vector2i(1, 8),
		Vector2i(0, 8),
		Vector2i(0, 5),
		Vector2i(2, 5),
		Vector2i(2, 3),
		Vector2i(0, 3),
	]

	var result := await day.partition_polygon(polygon)

	print(result)

	assert_eq(result, [
		Rect2i(0, 0, 7, 3),
		Rect2i(2, 3, 5, 2),
		Rect2i(0, 5, 7, 1),
		Rect2i(0, 6, 5, 1),
		Rect2i(0, 7, 7, 1),
		Rect2i(1, 8, 6, 2),
	])
