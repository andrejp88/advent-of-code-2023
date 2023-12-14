class_name Day12

const Util := preload("res://src/util.gd")


class Row:
	var conditions: String
	var range_sizes: Array[int]

	func _init(p_conditions: String, p_range_sizes: Array[int]) -> void:
		self.conditions = p_conditions
		self.range_sizes = p_range_sizes

	func apply_part_2_twist() -> void:
		conditions = "?".join([conditions, conditions, conditions, conditions, conditions])

		var new_range_sizes: Array[int] = []
		range_sizes = [range_sizes, range_sizes, range_sizes, range_sizes, range_sizes].reduce(join_range_sizes_for_part_2, new_range_sizes)

	func join_range_sizes_for_part_2(acc: Array[int], e: Array[int]) -> Array[int]:
		acc.append_array(e)
		return acc

	func _to_string() -> String:
		return "Row(%s, %s)" % [
			"\"" + conditions + "\"",
			range_sizes,
		]


func part_1(input: String) -> int:
	var parsed := parse_input(input)
	var result: int = parsed.map(calculate_possible_arrangements).reduce(Util.sumi)
	return result


func part_2(input: String) -> int:
	var parsed := parse_input(input)

	for row: Row in parsed:
		row.apply_part_2_twist()

	var result: int = parsed.map(calculate_possible_arrangements).reduce(Util.sumi)
	return result


func parse_input(input: String) -> Array[Row]:
	var lines := Array(input.split("\n", false))
	var result: Array[Row] = []
	result.assign(lines.map(parse_row))
	return result


func parse_row(row: String) -> Row:
	var row_split := row.split(" ")
	var conditions := row_split[0]
	var range_sizes_source := row_split[1]

	var range_sizes: Array[int] = []

	range_sizes.assign(Array(range_sizes_source.split(",")).map(
		func(range_size_source: String) -> int:
			return int(range_size_source)
	))


	return Row.new(conditions, range_sizes)


func calculate_possible_arrangements(row: Row, should_print_debug: bool = false, indent: String = "") -> int:

	if should_print_debug:
		print("%sTesting %s" % [indent, row])

	if not is_total_damaged_count_valid(row, should_print_debug, indent):
		return 0

	var first_unknown_index := row.conditions.find("?")
	var damaged_range_description := describe_damaged_ranges(row.conditions)
	if first_unknown_index == -1:
		if is_arrangment_compliant(row, damaged_range_description, should_print_debug, indent):
			return 1
		return 0

	if not is_valid_arrangement_so_far(row, should_print_debug, indent):
		return 0


	# 5. Pascal's Optimization
	#
	# If the first unknown is part of a range surrounded by operational entries: .##..???.###...
	#                                                                                 ^
	# ... or is at the beginning: ??.##...##.
	#                             ^
	# ... or is at the end: ..##.#...???
	#                                ^
	# ...then we can figure out the number of valid combinations in this range and skip a bunch of
	# recursive calls.
	var index_of_first_beyond_range := first_unknown_index
	while row.conditions[index_of_first_beyond_range] == "?":
		index_of_first_beyond_range += 1
		if index_of_first_beyond_range == row.conditions.length():
			break

	if (
		first_unknown_index == 0 or
		row.conditions[first_unknown_index - 1] == "."
	) and (
		index_of_first_beyond_range >= row.conditions.length() or
		row.conditions[index_of_first_beyond_range] == "."
	):
		return pascals_optimization(row, damaged_range_description, index_of_first_beyond_range, should_print_debug, indent)


	if index_of_first_beyond_range - first_unknown_index >= 3: # I guess
		return pascals_convenience(row, index_of_first_beyond_range, should_print_debug, indent)


	# 6. Otherwise, there are still unknowns left so check all possible sub-arrangements
	return search_for_solutions(row, should_print_debug, indent + "\t")



func is_total_damaged_count_valid(row: Row, should_print_debug: bool, indent: String) -> bool:
	var num_damaged_actual_in_current_row := row.conditions.count("#")
	var num_damaged_desired_in_current_row: int = row.range_sizes.reduce(Util.sumi, 0)
	var max_damaged_possible_in_current_row: int = row.conditions.count("#") + row.conditions.count("?")

	if (
		num_damaged_actual_in_current_row > num_damaged_desired_in_current_row or
		max_damaged_possible_in_current_row < num_damaged_desired_in_current_row
	):
		if should_print_debug:
			print("%sSkipping sub-arrangements since there are too many or too few possible damaged entries." % [indent])
		return false

	return true


func get_indices_of_unknowns(row: Row) -> Array[int]:
	var indices_of_unknowns: Array[int] = []

	for i: int in row.conditions.length():
		var condition := row.conditions[i]
		if condition == "?":
			indices_of_unknowns.push_back(i)

	return indices_of_unknowns


func get_first_unknown_index(row: Row) -> int:
	for i: int in row.conditions.length():
		var condition := row.conditions[i]
		if condition == "?":
			return i

	return -1


func is_arrangment_compliant(row: Row, damaged_range_description: Array[int], should_print_debug: bool, indent: String) -> bool:
	if damaged_range_description == row.range_sizes:
		if should_print_debug:
			print("%sThis matches!" % [indent])
		return true
	else:
		# This arrangement isn't valid: There are no unknowns but damaged range description doesn't match
		if should_print_debug:
			print("%sThis doesn't match" % [indent])
		return false


func is_valid_arrangement_so_far(row: Row, should_print_debug: bool, indent: String) -> bool:
	var damaged_range_description_with_unfinished_result := describe_damaged_ranges_with_unfinished(row.conditions)
	var damaged_range_description_with_unfinisheds: Array[int] = damaged_range_description_with_unfinished_result[0]
	var last_entry_is_unfinished: bool = damaged_range_description_with_unfinished_result[1]

	for i: int in damaged_range_description_with_unfinisheds.size():
		if i == damaged_range_description_with_unfinisheds.size() - 1 and last_entry_is_unfinished:
			if damaged_range_description_with_unfinisheds[i] > row.range_sizes[i]:
				if should_print_debug:
					print("%sDescription of range so far does not match expected range description: %s does not start with %s" % [indent, row.range_sizes, damaged_range_description_with_unfinisheds])
				return false
		else:
			if damaged_range_description_with_unfinisheds[i] != row.range_sizes[i]:
				if should_print_debug:
					print("%sDescription of range so far does not match expected range description: %s does not start with %s" % [indent, row.range_sizes, damaged_range_description_with_unfinisheds])
				return false

	return true


func pascals_optimization(
	row: Row,
	damaged_range_description: Array[int],
	index_of_first_beyond_range: int,
	should_print_debug: bool,
	indent: String
) -> int:
	var first_unknown_index := row.conditions.find("?")
	var length_of_unknowns := index_of_first_beyond_range - first_unknown_index
	var max_damaged_ranges := ceili(length_of_unknowns / 2.0)
	var ranges_matched_so_far := damaged_range_description.size()
	var remaining_ranges := row.range_sizes.slice(ranges_matched_so_far, ranges_matched_so_far + max_damaged_ranges)

	if should_print_debug:
		print("%sRow has a clean batch of unknowns from %s to %s" % [indent, first_unknown_index, index_of_first_beyond_range])

	var known_combinations := 0

	for num_ranges_to_try: int in range(remaining_ranges.size(), -1, -1):
		var ranges_to_try := remaining_ranges.slice(0, num_ranges_to_try)
		var sum_of_ranges: int = 0 if ranges_to_try.is_empty() else ranges_to_try.reduce(Util.sumi)

		var number_of_arrangements := pascals_triangle(
			num_ranges_to_try,
			length_of_unknowns - sum_of_ranges - num_ranges_to_try + 1,
		)

		if should_print_debug:
			print("%s%s ways to fill the batch with these range sizes: %s" % [indent, number_of_arrangements, ranges_to_try])

		if number_of_arrangements == 0:
			continue

		var sample_success_conditions := fill_sample_conditions_from_range_sizes(row, ranges_to_try, index_of_first_beyond_range)

		known_combinations += number_of_arrangements * calculate_possible_arrangements(Row.new(sample_success_conditions, row.range_sizes), should_print_debug, indent + "\t")

	return known_combinations


func fill_sample_conditions_from_range_sizes(row: Row, ranges_to_try: Array[int], index_of_first_beyond_range: int) -> String:
	var sample_success_conditions := row.conditions
	var next_target_index := row.conditions.find("?")

	for range_length: int in ranges_to_try:
		for i: int in range_length:
			sample_success_conditions[next_target_index] = "#"
			next_target_index += 1

		if next_target_index >= sample_success_conditions.length():
			break

		sample_success_conditions[next_target_index] = "."
		next_target_index += 1

	# Fill in the rest with operationals, if needed
	while next_target_index < index_of_first_beyond_range:
		sample_success_conditions[next_target_index] = "."
		next_target_index += 1

	return sample_success_conditions


var total_solutions_from_idealized := 0
var total_solutions_from_semi_left := 0
var total_solutions_from_semi_right := 0
var total_solutions_from_non_ideal := 0


func pascals_convenience(row: Row, index_of_first_beyond_range: int, should_print_debug: bool, indent: String) -> int:
	if should_print_debug:
		print("%sTesting with idealized conditions" % [indent])

	var num_possible_arrangements := 0
	var first_unknown_index := row.conditions.find("?")

	var idealized_conditions := row.conditions
	idealized_conditions[first_unknown_index] = "."
	idealized_conditions[index_of_first_beyond_range - 1] = "."
	var solutions_from_idealized := calculate_possible_arrangements(Row.new(idealized_conditions, row.range_sizes), should_print_debug, indent + "\t")
	num_possible_arrangements += solutions_from_idealized
	if indent == "":
		total_solutions_from_idealized += solutions_from_idealized

	# We do the other two possible combinations manually so we can skip part 6

	var semi_ideal_conditions_left := row.conditions
	semi_ideal_conditions_left[first_unknown_index] = "."
	semi_ideal_conditions_left[index_of_first_beyond_range - 1] = "#"
	var solutions_from_semi_left := calculate_possible_arrangements(Row.new(semi_ideal_conditions_left, row.range_sizes), should_print_debug, indent + "\t")
	num_possible_arrangements += solutions_from_semi_left
	if indent == "":
		total_solutions_from_semi_left += solutions_from_semi_left

	var semi_ideal_conditions_right := row.conditions
	semi_ideal_conditions_right[first_unknown_index] = "#"
	semi_ideal_conditions_right[index_of_first_beyond_range - 1] = "."
	var solutions_from_semi_right := calculate_possible_arrangements(Row.new(semi_ideal_conditions_right, row.range_sizes), should_print_debug, indent + "\t")
	num_possible_arrangements += solutions_from_semi_right
	if indent == "":
		total_solutions_from_semi_right += solutions_from_semi_right

	var non_ideal_conditions := row.conditions
	non_ideal_conditions[first_unknown_index] = "#"
	non_ideal_conditions[index_of_first_beyond_range - 1] = "#"
	var solutions_from_non_ideal := calculate_possible_arrangements(Row.new(non_ideal_conditions, row.range_sizes), should_print_debug, indent + "\t")
	num_possible_arrangements += solutions_from_non_ideal
	if indent == "":
		total_solutions_from_non_ideal += solutions_from_non_ideal

	return num_possible_arrangements


func search_for_solutions(row: Row, should_print_debug: bool, indent: String) -> int:
	var num_possible_sub_arrangements := 0
	var first_unknown_index := row.conditions.find("?")

	var with_first_unknown_operational := row.conditions
	with_first_unknown_operational[first_unknown_index] = "."
	var operational_row := Row.new(with_first_unknown_operational, row.range_sizes)
	num_possible_sub_arrangements += calculate_possible_arrangements(operational_row, should_print_debug, indent + "\t")

	var with_first_unknown_damaged := row.conditions
	with_first_unknown_damaged[first_unknown_index] = "#"
	var damaged_row := Row.new(with_first_unknown_damaged, row.range_sizes)
	num_possible_sub_arrangements += calculate_possible_arrangements(damaged_row, should_print_debug, indent + "\t")

	return num_possible_sub_arrangements


func describe_damaged_ranges(conditions: String) -> Array[int]:

	var result: Array[int] = []
	var start_new := true

	for condition: String in conditions:
		match condition:
			".":
				start_new = true

			"#":
				if start_new:
					start_new = false
					result.push_back(1)
				else:
					result[result.size() - 1] += 1

			"?":
				if not start_new:
					# Discard the ongoing one since we can't be sure of its length.
					result.pop_back()
				break

			_:
				printerr("Unexpected Condition in match expression: ", condition)

	return result


func describe_damaged_ranges_with_unfinished(conditions: String) -> Array:

	var result: Array[int] = []
	var start_new := true
	var last_entry_is_unfinished := false

	for condition: String in conditions:
		match condition:
			".":
				start_new = true

			"#":
				if start_new:
					start_new = false
					result.push_back(1)
				else:
					result[result.size() - 1] += 1

			"?":
				if not start_new:
					last_entry_is_unfinished = true
				break

			_:
				printerr("Unexpected Condition in match expression: ", condition)

	return [result, last_entry_is_unfinished]


func pascals_triangle(a: int, b: int) -> int:
	if a < 0 or b < 0:
		return 0

	if a == 0 or b == 0:
		return 1

	return pascals_triangle(a - 1, b) + pascals_triangle(a, b - 1)


func permutations_no_duplicates(array: Array[int]) -> int:
	var sorted := array.duplicate()
	sorted.sort()
	var counts := {}

	for n: int in sorted:
		if n in counts:
			counts[n] += 1
		else:
			counts[n] = 1

	var result := factorial(sorted.size())

	for n: int in counts.values():
		result /= factorial(n)

	return result


func factorial(n: int) -> int:
	if n == 0 or n == 1:
		return 1
	else:
		return n * factorial(n - 1)
