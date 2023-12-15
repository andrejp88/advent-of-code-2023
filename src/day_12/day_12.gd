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


func optimize_caches() -> void:
	for key: String in cpa_cache.keys():
		if cpa_cache[key][1] == 1:
			cpa_cache.erase(key)

	for key: String in describe_damaged_ranges_cache.keys():
		if describe_damaged_ranges_cache[key][1] == 1:
			describe_damaged_ranges_cache.erase(key)

	for key: String in describe_damaged_ranges_with_unfinished_cache.keys():
		if describe_damaged_ranges_with_unfinished_cache[key][1] == 1:
			describe_damaged_ranges_with_unfinished_cache.erase(key)


# Only cache the more time consuming computations to save memory
var cpa_cache := {}

func calculate_possible_arrangements(row: Row, should_print_debug: bool = false, indent: String = "") -> int:

	var row_string := str(row).lstrip(".").rstrip(".")
	if row_string in cpa_cache:
		cpa_cache[row_string][1] += 1
		return cpa_cache[row_string][0]


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


	var nice_unknown_batch_regex := RegEx.new()
	nice_unknown_batch_regex.compile(r"\.\?+\.|^\?+\.|\.\?+$")
	#                                 ".???.", or "???." at the start, or ".???" at the end
	var nice_unknown_batch_regex_result := nice_unknown_batch_regex.search_all(row.conditions)
	var closest_to_middle_batch: RegExMatch = null

	@warning_ignore("integer_division")
	var index_of_middle := row.conditions.length() / 2

	for batch_match: RegExMatch in nice_unknown_batch_regex_result:
		if (
			closest_to_middle_batch == null or
			absi(index_of_middle - batch_match.get_start()) < absi(index_of_middle - closest_to_middle_batch.get_start())
		):
			closest_to_middle_batch = batch_match

	if closest_to_middle_batch != null:
		var pascals_optimization_result := pascals_optimization(row, closest_to_middle_batch, should_print_debug, indent + "\t")
		cpa_cache[row_string] = [pascals_optimization_result, 1]
		return pascals_optimization_result


	var index_of_first_beyond_range := first_unknown_index
	while row.conditions[index_of_first_beyond_range] == "?":
		index_of_first_beyond_range += 1
		if index_of_first_beyond_range == row.conditions.length():
			break

	if index_of_first_beyond_range - first_unknown_index >= 3: # I guess
		var pascals_convenience_result := pascals_convenience(row, index_of_first_beyond_range, should_print_debug, indent)
		cpa_cache[row_string] = [pascals_convenience_result, 1]
		return pascals_convenience_result


	# 6. Otherwise, there are still unknowns left so check all possible sub-arrangements
	var search_result := search_for_solutions(row, should_print_debug, indent + "\t")
	cpa_cache[row_string] = [search_result, 1]
	return search_result



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
	var last_entry_max_possible_size: int = damaged_range_description_with_unfinished_result[1]
	var last_entry_is_unfinished := last_entry_max_possible_size == 0 or last_entry_max_possible_size != damaged_range_description_with_unfinisheds[damaged_range_description_with_unfinisheds.size() - 1]

	for i: int in damaged_range_description_with_unfinisheds.size():
		if i == damaged_range_description_with_unfinisheds.size() - 1 and last_entry_is_unfinished:
			if damaged_range_description_with_unfinisheds[i] > row.range_sizes[i] or last_entry_max_possible_size < row.range_sizes[i]:
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
	closest_to_middle_batch: RegExMatch,
	should_print_debug: bool,
	indent: String
) -> int:
	if should_print_debug:
		print("%sRow has a clean batch of unknowns from %s to %s" % [indent, closest_to_middle_batch.get_start() + 1, closest_to_middle_batch.get_end() - 1])

	var known_combinations := 0
	var length_of_unknowns := closest_to_middle_batch.get_string().count("?")

	# For optimizing the loop
	var did_left_ever_succeed := false

	for num_ranges_to_try_left: int in row.range_sizes.size() + 1:
		var ranges_left := row.range_sizes.slice(0, num_ranges_to_try_left)

		for num_ranges_to_try_middle: int in row.range_sizes.size() + 1 - num_ranges_to_try_left:
			var ranges_middle := row.range_sizes.slice(num_ranges_to_try_left, num_ranges_to_try_left + num_ranges_to_try_middle)

			if should_print_debug:
				print("%sTrying these range sizes in the middle: %s" % [indent + "\t", ranges_middle])

			var sum_of_ranges_middle: int = 0 if ranges_middle.is_empty() else ranges_middle.reduce(Util.sumi)

			var middle_arrangements := pascals_triangle(
				ranges_middle.size(),
				length_of_unknowns - sum_of_ranges_middle - ranges_middle.size() + 1,
			)

			if should_print_debug:
				print("%s%s ways to fill the middle batch with these range sizes: %s" % [indent + "\t", middle_arrangements, ranges_middle])

			if middle_arrangements == 0:
				if should_print_debug:
					print("%sSkipping remaining middle sub-range attempts" % [indent + "\t"])
				break

			var ranges_right := row.range_sizes.slice(num_ranges_to_try_left + num_ranges_to_try_middle, row.range_sizes.size())

			if should_print_debug:
				print("%sTrying these range sizes on the left %s, middle %s, and right %s" % [indent + "\t", ranges_left, ranges_middle, ranges_right])

			var left_arrangements := calculate_possible_arrangements(
				Row.new(row.conditions.substr(0, closest_to_middle_batch.get_start()), ranges_left), should_print_debug, indent + "\t" + "\t"
			)

			if left_arrangements == 0:
				if did_left_ever_succeed:
					if should_print_debug:
						print("%sLeft range has gotten too big and can't fit anymore. Skipping remaining attempts." % [indent + "\t"])
					return known_combinations

			else:
				did_left_ever_succeed = true

			var right_arrangements := calculate_possible_arrangements(
				Row.new(row.conditions.substr(closest_to_middle_batch.get_end()), ranges_right), should_print_debug, indent + "\t" + "\t"
			)

			known_combinations += middle_arrangements * left_arrangements * right_arrangements


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


var describe_damaged_ranges_unique_calls := 0
var describe_damaged_ranges_total_calls := 0
var describe_damaged_ranges_cache := {}

func describe_damaged_ranges(conditions: String) -> Array[int]:

	describe_damaged_ranges_total_calls += 1

	var conditions_stripped := conditions.lstrip(".").rstrip(".")
	if conditions_stripped in describe_damaged_ranges_cache:
		describe_damaged_ranges_cache[conditions_stripped][1] += 1
		return describe_damaged_ranges_cache[conditions_stripped][0]

	describe_damaged_ranges_unique_calls += 1

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

	describe_damaged_ranges_cache[conditions_stripped] = [result, 1]

	return result


var describe_damaged_ranges_with_unfinished_unique_calls := 0
var describe_damaged_ranges_with_unfinished_total_calls := 0
var describe_damaged_ranges_with_unfinished_cache := {}

func describe_damaged_ranges_with_unfinished(conditions: String) -> Array:

	describe_damaged_ranges_with_unfinished_total_calls += 1

	var conditions_stripped := conditions.lstrip(".").rstrip(".")
	if conditions_stripped in describe_damaged_ranges_with_unfinished_cache:
		describe_damaged_ranges_with_unfinished_cache[conditions_stripped][1] += 1
		return describe_damaged_ranges_with_unfinished_cache[conditions_stripped][0]

	describe_damaged_ranges_with_unfinished_unique_calls += 1

	var result: Array[int] = []
	var start_new := true
	var last_entry_max_possible_size := 0
	var getting_last_entry_max_size := false

	for condition: String in conditions:
		match condition:
			".":
				if getting_last_entry_max_size:
					break
				start_new = true

			"#":
				if start_new:
					start_new = false
					result.push_back(1)
				elif getting_last_entry_max_size:
					last_entry_max_possible_size += 1
				else:
					result[result.size() - 1] += 1

			"?":
				if getting_last_entry_max_size:
					last_entry_max_possible_size += 1
				elif start_new:
					if result.size() > 0:
						last_entry_max_possible_size = result[result.size() - 1]
					break
				else:
					getting_last_entry_max_size = true
					last_entry_max_possible_size = result[result.size() - 1] + 1

			_:
				printerr("Unexpected Condition in match expression: ", condition)

	if last_entry_max_possible_size == 0 and result.size() > 0:
		last_entry_max_possible_size = result[result.size() - 1]

	describe_damaged_ranges_with_unfinished_cache[conditions_stripped] = [[result, last_entry_max_possible_size], 1]

	return [result, last_entry_max_possible_size]


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
