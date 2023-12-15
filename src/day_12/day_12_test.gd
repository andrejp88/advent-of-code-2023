extends GutTest


var day: Day12
var test_input_parsed := [
	Day12.Row.new("???.###", [1, 1, 3]),
	Day12.Row.new(".??..??...?##.", [1, 1, 3]),
	Day12.Row.new("?#?#?#?#?#?#?#?", [1, 3, 1, 6]),
	Day12.Row.new("????.#...#...", [4, 1, 1]),
	Day12.Row.new("????.######..#####.", [1, 6, 5]),
	Day12.Row.new("?###????????", [3, 2, 1]),
]

var test_input_parsed_part_2: Array[Day12.Row] = (
	func() -> Array[Day12.Row]:
		var result: Array[Day12.Row] = [
			Day12.Row.new("???.###", [1, 1, 3]),
			Day12.Row.new(".??..??...?##.", [1, 1, 3]),
			Day12.Row.new("?#?#?#?#?#?#?#?", [1, 3, 1, 6]),
			Day12.Row.new("????.#...#...", [4, 1, 1]),
			Day12.Row.new("????.######..#####.", [1, 6, 5]),
			Day12.Row.new("?###????????", [3, 2, 1]),
		]

		for row: Day12.Row in result:
			row.apply_part_2_twist()

		return result
).call()


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

	assert_eq(day.part_2(input), 525_152)


# Seems to not work if it's a local variable
var part_2_real_total := 0

func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_12/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var parsed := day.parse_input(input)
	var threads: Array[Thread] = []
	var mutex := Mutex.new()
	var alive_threads := 0

	for row_idx: int in parsed.size():
		var row := parsed[row_idx]
		row.apply_part_2_twist()

		var thread := Thread.new()
		threads.push_back(thread)

		thread.start(
			func() -> void:
				var result := day.calculate_possible_arrangements(row)
				mutex.lock()
				part_2_real_total += result
				print("Row %04d finished with result %s, running total = %s" % [row_idx + 1, result, part_2_real_total])
				mutex.unlock()
		)
		alive_threads += 1


	var last_notification_time := Time.get_unix_time_from_system()

	while alive_threads > 0:
		for thread: Thread in threads:
			if not thread.is_alive():
				thread.wait_to_finish()
				threads.erase(thread)
				alive_threads -= 1

		var current_time := Time.get_unix_time_from_system()
		if current_time - last_notification_time > 10.0:
			last_notification_time = current_time
			print("%s threads are still alive" % [alive_threads])

	mutex.lock()
	print("Day 12, Part 2: ", part_2_real_total)
	mutex.unlock()
	pass_test("passed")


func test_parse_input() -> void:
	var fa := FileAccess.open("res://src/day_12/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var result := day.parse_input(input)
	assert_eq(result.size(), test_input_parsed.size())

	for i: int in result.size():
		assert_rows_eq(result[i], test_input_parsed[i])


func test_calculate_possible_arrangements_part_1() -> void:
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[0]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[1]), 4)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[2]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[3]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[4]), 4)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed[5]), 10)


func test_describe_damaged_ranges() -> void:
	assert_eq(day.describe_damaged_ranges("#.#.###"), [1, 1, 3])
	assert_eq(day.describe_damaged_ranges("###.###"), [3, 3])
	assert_eq(day.describe_damaged_ranges("#"), [1])
	assert_eq(day.describe_damaged_ranges(".#."), [1])
	assert_eq(day.describe_damaged_ranges("."), [])
	assert_eq(day.describe_damaged_ranges(".#.?.##"), [1])
	assert_eq(day.describe_damaged_ranges(".#.##?"), [1])


func test_describe_damaged_ranges_with_unfinished() -> void:
	assert_eq(day.describe_damaged_ranges_with_unfinished("#.#.###"), [[1, 1, 3], 3])
	assert_eq(day.describe_damaged_ranges_with_unfinished("###.###"), [[3, 3], 3])
	assert_eq(day.describe_damaged_ranges_with_unfinished("#"), [[1], 1])
	assert_eq(day.describe_damaged_ranges_with_unfinished(".#."), [[1], 1])
	assert_eq(day.describe_damaged_ranges_with_unfinished("."), [[], 0])
	assert_eq(day.describe_damaged_ranges_with_unfinished(".#.?.##"), [[1], 1])
	assert_eq(day.describe_damaged_ranges_with_unfinished(".#.##?"), [[1, 2], 3])
	assert_eq(day.describe_damaged_ranges_with_unfinished(".#.##????.#"), [[1, 2], 6])
	assert_eq(day.describe_damaged_ranges_with_unfinished(".#.##????##"), [[1, 2], 8])


func test_apply_part_2_twist() -> void:
	var row := Day12.Row.new(".#", [1])
	row.apply_part_2_twist()
	assert_rows_eq(row, Day12.Row.new(".#?.#?.#?.#?.#", [1, 1, 1, 1, 1]))


func test_calculate_possible_arrangements_part_2() -> void:
	var start_time := Time.get_unix_time_from_system()
	assert_eq(day.calculate_possible_arrangements(test_input_parsed_part_2[0]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed_part_2[1]), 16384)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed_part_2[2]), 1)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed_part_2[3]), 16)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed_part_2[4]), 2500)
	assert_eq(day.calculate_possible_arrangements(test_input_parsed_part_2[5]), 506250)
	print("Time elapsed: %.3f" % [Time.get_unix_time_from_system() - start_time])

	var fa := FileAccess.open("res://src/day_12/cpa_cache_test_calculate_possible_arrangements_part_2.json", FileAccess.WRITE)
	fa.store_string(str(day.cpa_cache))
	fa.close()


func test_calculate_possible_arrangements_problematic_part_2_1() -> void:
	var row := day.parse_row("???.????.?..????? 3,1,1,3")
	row.apply_part_2_twist()
	var start_time := Time.get_unix_time_from_system()
	var result := day.calculate_possible_arrangements(row)
	print("Time elapsed: %.3f" % [Time.get_unix_time_from_system() - start_time])
	print(result)
	pass_test("passed")


func test_calculate_possible_arrangements_problematic_part_2_row_1() -> void:
	var row := day.parse_row("???????????#??? 5,2,1")
	row.apply_part_2_twist()
	var start_time := Time.get_unix_time_from_system()
	var result := day.calculate_possible_arrangements(row)
	print("Time elapsed: %.3f" % [Time.get_unix_time_from_system() - start_time])
	print(result)
	pass_test("passed")


func test_calculate_possible_arrangements_problematic_part_2_2() -> void:
	var row := day.parse_row("?#??????#???????? 12,1")
	row.apply_part_2_twist()
	var start_time := Time.get_unix_time_from_system()
	var result := day.calculate_possible_arrangements(row)
	print("Time elapsed: %.3f" % [Time.get_unix_time_from_system() - start_time])
	print(result)
	pass_test("passed")


func test_pascals_triangle() -> void:
	assert_eq(day.pascals_triangle(0, 0), 1)
	assert_eq(day.pascals_triangle(0, 1), 1)
	assert_eq(day.pascals_triangle(1, 0), 1)
	assert_eq(day.pascals_triangle(20, 0), 1)
	assert_eq(day.pascals_triangle(0, 20), 1)
	assert_eq(day.pascals_triangle(1, 1), 2)
	assert_eq(day.pascals_triangle(1, 2), 3)
	assert_eq(day.pascals_triangle(1, 3), 4)
	assert_eq(day.pascals_triangle(3, 4), 35)
	assert_eq(day.pascals_triangle(4, 3), 35)


func test_permutations_no_duplicates() -> void:
	assert_eq(day.permutations_no_duplicates([]), 1)
	assert_eq(day.permutations_no_duplicates([1]), 1)
	assert_eq(day.permutations_no_duplicates([1, 1]), 1)
	assert_eq(day.permutations_no_duplicates([1, 2]), 2)
	assert_eq(day.permutations_no_duplicates([1, 2, 3]), 6)
	assert_eq(day.permutations_no_duplicates([1, 2, 2]), 3)
	assert_eq(day.permutations_no_duplicates([2, 2, 2]), 1)
	assert_eq(day.permutations_no_duplicates([2, 2, 2]), 1)
	assert_eq(day.permutations_no_duplicates([1, 1, 1, 1]), 1)
	assert_eq(day.permutations_no_duplicates([1, 1, 1, 2]), 4)
	assert_eq(day.permutations_no_duplicates([1, 1, 2, 2]), 6)
	assert_eq(day.permutations_no_duplicates([1, 1, 2, 3]), 12)
