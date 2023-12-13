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


var unique_calls_to_cpa := {}


func calculate_possible_arrangements(row: Row, should_print_debug: bool = false, indent: String = "") -> int:

	unique_calls_to_cpa[str(row)] = true

	if should_print_debug:
		print("%sTesting %s" % [indent, row])

	# 1. Optimization: Fail if total number of damaged entries is wrong
	var num_damaged_actual_in_current_row := row.conditions.count("#")
	var num_damaged_desired_in_current_row: int = row.range_sizes.reduce(Util.sumi, 0)
	var max_damaged_possible_in_current_row: int = row.conditions.count("#") + row.conditions.count("?")

	if (
		num_damaged_actual_in_current_row > num_damaged_desired_in_current_row or
		max_damaged_possible_in_current_row < num_damaged_desired_in_current_row
	):
		if should_print_debug:
			print("%sSkipping sub-arrangements since there are too many or too few possible damaged entries." % [indent])
		return 0


	# 2. Get remaining unknown indices
	var indices_of_unknowns: Array[int] = []

	for i: int in row.conditions.length():
		var condition := row.conditions[i]
		if condition == "?":
			indices_of_unknowns.push_back(i)


	# 3. No more unknowns left? Check if this is a valid arrangement
	var damaged_range_description := describe_damaged_ranges(row.conditions)

	if indices_of_unknowns.is_empty():
		if damaged_range_description == row.range_sizes:
			if should_print_debug:
				print("%sThis matches!" % [indent])
			return 1
		else:
			# This arrangement isn't valid: There are no unknowns but damaged range description doesn't match
			if should_print_debug:
				print("%sThis doesn't match" % [indent])
			return 0


	# 4. Optimization: Check if it's a valid arrangement so far
	var damaged_range_description_with_unfinisheds := describe_damaged_ranges_with_unfinished(row.conditions)
	for i: int in damaged_range_description_with_unfinisheds.size():
		if i == damaged_range_description_with_unfinisheds.size() - 1:
			if damaged_range_description_with_unfinisheds[i] > row.range_sizes[i]:
				if should_print_debug:
					print("%sDescription of range so far does not match expected range description: %s does not start with %s" % [indent, row.range_sizes, damaged_range_description_with_unfinisheds])
				return 0
		else:
			if damaged_range_description_with_unfinisheds[i] != row.range_sizes[i]:
				if should_print_debug:
					print("%sDescription of range so far does not match expected range description: %s does not start with %s" % [indent, row.range_sizes, damaged_range_description_with_unfinisheds])
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

	var index_of_first_beyond_range := indices_of_unknowns[0]
	while row.conditions[index_of_first_beyond_range] == "?":
		index_of_first_beyond_range += 1
		if index_of_first_beyond_range == row.conditions.length():
			break

	if (
		indices_of_unknowns[0] == 0 or
		row.conditions[indices_of_unknowns[0] - 1] == "."
	):
		if (
			index_of_first_beyond_range >= row.conditions.length() or
			row.conditions[index_of_first_beyond_range] == "."
		):

			var length_of_unknowns := index_of_first_beyond_range - indices_of_unknowns[0]
			var max_damaged_ranges := ceili(length_of_unknowns / 2.0)
			var ranges_matched_so_far := damaged_range_description.size()
			var remaining_ranges := row.range_sizes.slice(ranges_matched_so_far, ranges_matched_so_far + max_damaged_ranges)

			if should_print_debug:
				print("%sRow has a clean batch of unknowns from %s to %s" % [indent, indices_of_unknowns[0], index_of_first_beyond_range])

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

				var sample_success_conditions := row.conditions
				var next_target_index := indices_of_unknowns[0]


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

				known_combinations += number_of_arrangements * calculate_possible_arrangements(Row.new(sample_success_conditions, row.range_sizes), should_print_debug, indent + "\t")

			return known_combinations


	# 5.1 Create convenient ranges if they don't yet exist for section 5
	if index_of_first_beyond_range - indices_of_unknowns[0] >= 3: # I guess
		if should_print_debug:
			print("%sTesting with idealized conditions" % [indent])

		var num_possible_arrangements := 0

		var idealized_conditions := row.conditions
		idealized_conditions[indices_of_unknowns[0]] = "."
		idealized_conditions[index_of_first_beyond_range - 1] = "."
		num_possible_arrangements += calculate_possible_arrangements(Row.new(idealized_conditions, row.range_sizes), should_print_debug, indent + "\t")

		# We do the other two possible combinations manually so we can skip part 6

		var semi_ideal_conditions_left := row.conditions
		semi_ideal_conditions_left[indices_of_unknowns[0]] = "."
		semi_ideal_conditions_left[index_of_first_beyond_range - 1] = "#"
		num_possible_arrangements += calculate_possible_arrangements(Row.new(semi_ideal_conditions_left, row.range_sizes), should_print_debug, indent + "\t")

		var semi_ideal_conditions_right := row.conditions
		semi_ideal_conditions_right[indices_of_unknowns[0]] = "#"
		semi_ideal_conditions_right[index_of_first_beyond_range - 1] = "."
		num_possible_arrangements += calculate_possible_arrangements(Row.new(semi_ideal_conditions_right, row.range_sizes), should_print_debug, indent + "\t")

		var non_ideal_conditions := row.conditions
		non_ideal_conditions[indices_of_unknowns[0]] = "#"
		non_ideal_conditions[index_of_first_beyond_range - 1] = "#"
		num_possible_arrangements += calculate_possible_arrangements(Row.new(non_ideal_conditions, row.range_sizes), should_print_debug, indent + "\t")

		return num_possible_arrangements


	# 6. Otherwise, there are still unknowns left so check all possible sub-arrangements
	var num_possible_sub_arrangements := 0

	var with_first_unknown_operational := row.conditions
	with_first_unknown_operational[indices_of_unknowns[0]] = "."
	var operational_row := Row.new(with_first_unknown_operational, row.range_sizes)
	num_possible_sub_arrangements += calculate_possible_arrangements(operational_row, should_print_debug, indent + "\t")

	var with_first_unknown_damaged := row.conditions
	with_first_unknown_damaged[indices_of_unknowns[0]] = "#"
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


func describe_damaged_ranges_with_unfinished(conditions: String) -> Array[int]:

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
				break

			_:
				printerr("Unexpected Condition in match expression: ", condition)

	return result


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
